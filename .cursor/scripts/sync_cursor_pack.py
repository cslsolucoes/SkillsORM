#!/usr/bin/env python3
"""
Sincroniza o pack .cursor/ de um projeto fonte para um ou mais projetos destino.
Cross-platform: Windows, Linux, macOS.

Equivalente ao sync-cursor-pack.ps1 (substitui robocopy /MIR por comparação de mtime/size).
Não depende de pack-inventory.json. O índice canónico do pack é `.cursor/index.db`
(FTS5), atualizado por `pack_index_db.py` (command `/syncdb`).

Uso:
    python3 sync_cursor_pack.py --dest PATH [PATH ...] [--whatif] [--force]

Exit codes:
    0 = sucesso sem avisos
    2 = fonte não encontrada
    3 = sucesso com avisos (refs quebradas pós-cópia)
    4 = erros ocorreram

internal_file_version: 1.2.0
Changelog:
    - 1.2.0 (25/04/2026): Removida dependência de pack-inventory.json. Sync passa a operar
      apenas via cópia por mtime/size e validação pós-cópia; indexação do pack é feita por
      `pack_index_db.py` (`/syncdb`).
    - 1.1.0 (09/04/2026): Sync seletivo por versão semântica via
      pack-inventory.json; roda gen_pack_inventory.py --incremental após sync.
    - 1.0.0 (09/04/2026): Versão inicial cross-platform. Equivalente ao
      sync-cursor-pack.ps1 para Windows/Linux/macOS.
"""

import sys
import json
import shutil
import fnmatch
import argparse
import re
import subprocess
from pathlib import Path
from datetime import datetime

# Forçar UTF-8 no console Windows
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

# ---------------------------------------------------------------------------
# Constantes (idênticas ao sync-cursor-pack.ps1)
# ---------------------------------------------------------------------------

PACK_DIRS = ['scripts', 'skills', 'Templates', 'agents', 'plans', 'commands', 'rules']

PACK_FILES = ['README.md', 'VERSION.md', 'config.json']

OBSOLETE_DIRS = ['Constitution', 'Developer']

OBSOLETE_FILES = [
    'compile.md', 'database.md', 'diretivas_compilacao.md',
    'SKILLS_DOCUMENTATION_v3.0.8.md', 'SKILLS_DOCUMENTATION_v3.0.7.md',
    'MIRRORS_VALIDATION.md', 'BASE_STRUCTURE.md',
]

DEPRECATED_SKILL_PATTERNS = [
    'cursor-rules-integration*',
    'migration-conflict-resolution_V1.0.1*',
    'superseded-definition*',
]

# ---------------------------------------------------------------------------
# Estado global de contadores
# ---------------------------------------------------------------------------

class SyncState:
    def __init__(self, whatif: bool):
        self.whatif  = whatif
        self.copied  = 0
        self.removed = 0
        self.orphans = 0
        self.warnings = 0
        self.errors  = 0

# Helpers
# ---------------------------------------------------------------------------

def resolve_source_root() -> Path:
    """scripts/ → .cursor/ → raiz do repo."""
    root = Path(__file__).resolve().parent.parent.parent
    cursor = root / '.cursor'
    if not cursor.is_dir():
        print(f'[ERRO] .cursor/ não encontrado em: {root}')
        sys.exit(2)
    return root

def detect_project_name(root: Path) -> str:
    """Tenta derivar o nome do projeto do .dpr/.lpr. Fallback: nome da pasta."""
    name = root.name
    for ext in ('*.dpr', '*.lpr'):
        candidates = [p for p in root.glob(ext) if '.template' not in p.name]
        if candidates:
            try:
                text = candidates[0].read_text(encoding='utf-8', errors='ignore')
                m = re.search(r'^\s*program\s+(\w+)\s*;', text, re.MULTILINE)
                if m:
                    name = m.group(1)
            except Exception:
                pass
            break
    return name

def remove_obsolete_items(dest_cursor: Path, state: SyncState) -> None:
    """Remove pastas, ficheiros e skills obsoletos/deprecados do destino."""
    # Pastas obsoletas
    for name in OBSOLETE_DIRS:
        path = dest_cursor / name
        if path.exists():
            if state.whatif:
                print(f'  [WHATIF]   Removeria {name}/ (obsoleto)')
            else:
                try:
                    shutil.rmtree(path)
                    print(f'  [REMOVIDO] {name}/ (obsoleto)')
                    state.removed += 1
                except Exception as e:
                    print(f'  [ERRO]     Não foi possível remover {name}/: {e}')
                    state.errors += 1

    # Ficheiros obsoletos
    for name in OBSOLETE_FILES:
        path = dest_cursor / name
        if path.exists():
            if state.whatif:
                print(f'  [WHATIF]   Removeria {name} (obsoleto)')
            else:
                try:
                    path.unlink()
                    print(f'  [REMOVIDO] {name} (obsoleto)')
                    state.removed += 1
                except Exception as e:
                    print(f'  [ERRO]     Não foi possível remover {name}: {e}')
                    state.errors += 1

    # Skills deprecadas (por padrão fnmatch)
    skills_dir = dest_cursor / 'skills'
    if skills_dir.is_dir():
        for skill_folder in sorted(skills_dir.iterdir()):
            if not skill_folder.is_dir():
                continue
            for pattern in DEPRECATED_SKILL_PATTERNS:
                if fnmatch.fnmatch(skill_folder.name, pattern):
                    if state.whatif:
                        print(f'  [WHATIF]   Removeria skills/{skill_folder.name} (deprecada)')
                    else:
                        try:
                            shutil.rmtree(skill_folder)
                            print(f'  [REMOVIDO] skills/{skill_folder.name} (deprecada)')
                            state.removed += 1
                        except Exception as e:
                            print(f'  [ERRO]     Não foi possível remover skills/{skill_folder.name}: {e}')
                            state.errors += 1
                    break

TOKEN_SUBST_EXTS = {'.md', '.mdc'}
TOKEN_PATTERN    = re.compile(r'\{NOME_PROJETO\}')

def copy_with_token_subst(src: Path, dst: Path, dest_name: str,
                          source_name: str = '') -> None:
    """
    Copia src → dst em .md/.mdc substituindo:
      {NOME_PROJETO}  → dest_name  (token template)
      source_name     → dest_name  (quando autostart já consumiu o token na fonte)
    Para outros tipos usa shutil.copy2 puro.
    """
    if src.suffix in TOKEN_SUBST_EXTS:
        try:
            content = src.read_text(encoding='utf-8', errors='replace')
            # 1. Token puro
            content = TOKEN_PATTERN.sub(dest_name, content)
            # 2. Nome da fonte (se diferente do destino e não vazio)
            if source_name and source_name != dest_name:
                src_pat = re.compile(rf'\b{re.escape(source_name)}\b(?!\.[A-Za-z])')
                content = src_pat.sub(dest_name, content)
            dst.write_text(content, encoding='utf-8')
            # Preservar timestamps
            st = src.stat()
            import os
            os.utime(dst, (st.st_atime, st.st_mtime))
        except Exception:
            shutil.copy2(src, dst)  # fallback
    else:
        shutil.copy2(src, dst)

def sync_directory(src: Path, dst: Path, label: str, force: bool, state: SyncState,
                   project_name: str = '', source_name: str = '',
                   src_versions: dict | None = None,
                   dst_versions: dict | None = None) -> None:
    """
    Espelha src → dst: copia novos/atualizados, remove órfãos.
    Equivale a robocopy /MIR.
    Substitui {NOME_PROJETO} em .md/.mdc pelo nome do projeto destino.
    Usa src_versions/dst_versions para prioridade semântica de versão.
    """
    if not src.exists():
        print(f'  [N/A]      {label} — pasta fonte não existe')
        return

    src_versions = src_versions or {}
    dst_versions = dst_versions or {}
    changed = False

    if not state.whatif:
        dst.mkdir(parents=True, exist_ok=True)

    # --- Copiar novos / atualizados ---
    for item in sorted(src.rglob('*')):
        rel       = item.relative_to(src)
        dest_item = dst / rel

        if item.is_dir():
            if not state.whatif:
                dest_item.mkdir(parents=True, exist_ok=True)
            continue

        # Chave relativa ao .cursor/ para lookup no inventário
        rel_key = (label + '/' + str(rel).replace('\\', '/')).lstrip('/')

        # Comparação de versão semântica (complementa mtime+size)
        src_ver = src_versions.get(rel_key)
        dst_ver = dst_versions.get(rel_key)
        version_newer = bool(
            src_ver and dst_ver and src_ver != dst_ver
            and _version_gt(src_ver, dst_ver)
        )

        needs_copy = (
            force
            or not dest_item.exists()
            or version_newer
            or item.stat().st_mtime > dest_item.stat().st_mtime + 1
            or item.stat().st_size  != dest_item.stat().st_size
        )
        if needs_copy:
            changed = True
            if not state.whatif:
                dest_item.parent.mkdir(parents=True, exist_ok=True)
                try:
                    copy_with_token_subst(item, dest_item, project_name, source_name)
                except Exception as e:
                    print(f'  [ERRO]     {label}/{rel}: {e}')
                    state.errors += 1

    # --- Remover órfãos (existem no destino mas não na fonte) ---
    if dst.exists():
        # Iterar em ordem reversa (arquivos antes de pastas)
        all_dest = sorted(dst.rglob('*'), reverse=True)
        for dest_item in all_dest:
            rel = dest_item.relative_to(dst)
            if not (src / rel).exists():
                changed = True
                if not state.whatif:
                    try:
                        if dest_item.is_dir() and not dest_item.is_symlink():
                            dest_item.rmdir()  # só remove se vazia (já removemos filhos antes)
                        else:
                            dest_item.unlink(missing_ok=True)
                        state.orphans += 1
                    except Exception:
                        pass  # pasta não vazia — será removida com os filhos

    if state.whatif:
        print(f'  [WHATIF]   Sincronizaria {label}')
    elif changed:
        print(f'  [SYNC]     {label}')
        state.copied += 1
    else:
        print(f'  [OK]       {label} (sem alterações)')

def sync_file(src: Path, dst: Path, label: str, state: SyncState,
              project_name: str = '', source_name: str = '') -> None:
    """Copia um único ficheiro da fonte para o destino."""
    if not src.exists():
        print(f'  [N/A]      {label} — ficheiro fonte não existe')
        return

    if state.whatif:
        print(f'  [WHATIF]   Copiaria {label}')
        return

    dst.parent.mkdir(parents=True, exist_ok=True)
    try:
        copy_with_token_subst(src, dst, project_name, source_name)
        print(f'  [SYNC]     {label}')
        state.copied += 1
    except Exception as e:
        print(f'  [ERRO]     {label}: {e}')
        state.errors += 1

def check_post_copy_coherence(dest_cursor: Path, state: SyncState) -> None:
    """
    Verifica coerência pós-cópia:
    - SKILL.md que referenciam templates/ → pasta deve existir
    - Refs a .cursor/Templates/ em .md/.mdc → template deve existir
    """
    # 1. SKILL.md com referência a templates/
    skills_dir = dest_cursor / 'skills'
    if skills_dir.is_dir():
        for skill_md in skills_dir.rglob('SKILL.md'):
            try:
                content = skill_md.read_text(encoding='utf-8', errors='ignore')
            except Exception:
                continue
            if 'templates/' in content:
                template_dir = skill_md.parent / 'templates'
                if not template_dir.is_dir():
                    print(f'  [AVISO]    {skill_md.relative_to(dest_cursor)} referencia templates/ mas pasta não existe')
                    state.warnings += 1

    # 2. Refs a .cursor/Templates/ em .md e .mdc
    pattern = re.compile(r'\.cursor/Templates/([^\s\)\]"\'`*<>]+)')
    for md_file in dest_cursor.rglob('*'):
        if md_file.suffix not in ('.md', '.mdc'):
            continue
        try:
            content = md_file.read_text(encoding='utf-8', errors='ignore')
        except Exception:
            continue
        for match in pattern.finditer(content):
            ref = match.group(1).rstrip(')]\'"`.* ;')
            if not ref:
                continue
            ref_path = dest_cursor / 'Templates' / ref
            if not ref_path.exists():
                rel = md_file.relative_to(dest_cursor)
                print(f'  [AVISO]    {rel} referencia Templates/{ref} — verificar')
                state.warnings += 1

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(
        description='Sincroniza o pack .cursor/ de um projeto fonte para projetos destino.'
    )
    parser.add_argument('--dest', nargs='+', required=True, metavar='PATH',
                        help='Caminho(s) absoluto(s) dos projetos destino.')
    parser.add_argument('--whatif', action='store_true',
                        help='Simula a execução sem alterar ficheiros.')
    parser.add_argument('--force', action='store_true',
                        help='Sobrescreve ficheiros no destino mesmo que mais recentes.')
    args = parser.parse_args()

    source_root   = resolve_source_root()
    source_cursor = source_root / '.cursor'

    print()
    print('=' * 64)
    print('  sync_cursor_pack — Sincronização do pack .cursor/')
    print('=' * 64)
    print()
    source_name = detect_project_name(source_root)
    print(f'[OK] Fonte: {source_root}  (projeto: {source_name})')
    if args.whatif:
        print('[INFO] Modo WhatIf — nenhum arquivo será alterado')

    # Índice por versão via inventário foi removido (indexação: /syncdb).
    src_versions: dict = {}
    print()

    global_state = SyncState(args.whatif)
    had_errors = False

    for dest_path_str in args.dest:
        dest_path = Path(dest_path_str.rstrip('/\\'))

        print('-' * 64)
        print(f'  Destino: {dest_path}')
        print('-' * 64)

        if not dest_path.is_dir():
            print(f'  [ERRO] Caminho não encontrado: {dest_path}')
            global_state.errors += 1
            had_errors = True
            continue

        dest_cursor  = dest_path / '.cursor'
        project_name = dest_path.name   # ex: ProvidersORM, SkillORM, ParamentersORM
        if not dest_cursor.exists() and not args.whatif:
            dest_cursor.mkdir(parents=True)
            print('  [CRIADO]   .cursor/')

        # Índice por versão via inventário foi removido (indexação: /syncdb).
        dst_versions: dict = {}

        state = SyncState(args.whatif)

        # 1. Remover obsoletos
        print()
        print('  --- Removendo obsoletos ---')
        remove_obsolete_items(dest_cursor, state)

        # 2. Sincronizar diretórios
        print()
        print('  --- Sincronizando diretórios ---')
        for dir_name in PACK_DIRS:
            sync_directory(
                source_cursor / dir_name,
                dest_cursor   / dir_name,
                dir_name,
                args.force,
                state,
                project_name,
                source_name,
                src_versions,
                dst_versions,
            )

        # 3. Sincronizar ficheiros raiz
        print()
        print('  --- Sincronizando ficheiros raiz ---')
        for file_name in PACK_FILES:
            sync_file(
                source_cursor / file_name,
                dest_cursor   / file_name,
                file_name,
                state,
                project_name,
                source_name,
            )

        # 4. Validação pós-cópia
        if not args.whatif:
            print()
            print('  --- Validação pós-cópia ---')
            check_post_copy_coherence(dest_cursor, state)
            if state.warnings == 0:
                print('  [OK]       Coerência OK — sem referências quebradas')

        # Acumular no estado global
        global_state.copied   += state.copied
        global_state.removed  += state.removed
        global_state.orphans  += state.orphans
        global_state.warnings += state.warnings
        global_state.errors   += state.errors

        print()
        print(f'  Copiados: {state.copied}  |  Removidos: {state.removed + state.orphans}  |  '
              f'Avisos: {state.warnings}  |  Erros: {state.errors}')

    # Reindex (opcional): o destino pode rodar `/syncdb` após o sync.
    if not args.whatif and global_state.errors == 0:
        print()
        print('  --- Reindex (opcional) ---')
        print('  Dica: rode `/syncdb` no destino para reindexar `.cursor/index.db`.')

    # Resumo global
    print()
    print('=' * 64)
    print('  Resumo global')
    print('=' * 64)
    print(f'  Copiados : {global_state.copied}')
    print(f'  Removidos: {global_state.removed + global_state.orphans}')
    print(f'  Avisos   : {global_state.warnings}')
    print(f'  Erros    : {global_state.errors}')
    print()

    if global_state.errors > 0:
        return 4
    if global_state.warnings > 0:
        return 3
    return 0


if __name__ == '__main__':
    sys.exit(main())
