#!/usr/bin/env python3
"""
Reset dos ficheiros de infraestrutura de IA ao estado base.
Cross-platform: Windows, Linux, macOS.

Remove APENAS os ficheiros criados pelos scripts de bootstrap:

    Da raiz:
      - Ficheiros rootFiles de cada IA habilitada (ex: CLAUDE.md, opencode.json)

    Dos mirrors (.claude/ .vscode/ .continue/ .opencode/):
      - settings.json, settings.local.json, extensions.json (configs geradas)
      - tasks.json restaurado do .bak (se AutoStart fez upgrade)
      - todos os symlinks (geridos por bootstrap_mirror_symlinks.py)
      - pastas vazias após remoção dos symlinks

    NÃO toca em:
      - Ficheiros de projeto Delphi/FPC (*.dpr, *.dproj, *.lpr, etc.)
      - src/, Documentation/, qualquer outro ficheiro do utilizador
      - .cursor/ (SSOT — imutável)
      - .vscode/tasks.json (preservado ou restaurado do .bak)

Uso:
    python3 bootstrap_reset.py [--whatif] [--force]

internal_file_version: 1.0.0
Changelog:
    - 1.0.0 (09/04/2026): Versão inicial cross-platform. Equivalente ao
      bootstrap-reset.ps1 para Windows/Linux/macOS.
"""

import os
import sys
import json
import shutil
import platform
from pathlib import Path
from datetime import datetime

# Forçar UTF-8 no console Windows
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

OS = platform.system()  # 'Windows' | 'Linux' | 'Darwin'

# ---------------------------------------------------------------------------
# Caminhos
# ---------------------------------------------------------------------------

SCRIPT_DIR = Path(__file__).resolve().parent   # .cursor/scripts/
CURSOR_DIR = SCRIPT_DIR.parent                 # .cursor/
REPO_ROOT  = CURSOR_DIR.parent                 # raiz do repo

# ---------------------------------------------------------------------------
# Configs conhecidos por mirror (removidos no reset)
# ---------------------------------------------------------------------------

KNOWN_CONFIGS: dict[str, list[str]] = {
    '.claude':   ['settings.json', 'settings.local.json'],
    '.vscode':   ['settings.json', 'extensions.json'],
    '.continue': ['config.json', 'config.yaml'],
    '.opencode': ['config.json'],
}

# Itens protegidos por mirror (nunca removidos)
PROTECTED_ITEMS: dict[str, list[str]] = {
    '.vscode': ['tasks.json'],
}

# ---------------------------------------------------------------------------
# Detecção de rede
# ---------------------------------------------------------------------------

def is_network_path(path: Path) -> bool:
    p = str(path)
    if p.startswith('\\\\') or p.startswith('//'):
        return True
    if OS == 'Windows':
        try:
            import ctypes
            DRIVE_REMOTE = 4
            if ctypes.windll.kernel32.GetDriveTypeW(p[:3]) == DRIVE_REMOTE:
                return True
        except Exception:
            pass
    if OS == 'Linux' and p.startswith('/mnt/'):
        return True
    if OS == 'Darwin' and p.startswith('/Volumes/'):
        return True
    return False

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

def load_mirror_config() -> dict:
    config_path = CURSOR_DIR / 'config.json'
    default = {
        'enabled_dirs': ['.claude', '.vscode', '.continue', '.opencode'],
        'root_files': ['CLAUDE.md', 'opencode.json'],
        'has_vscode': True,
    }
    if not config_path.exists():
        return default
    try:
        data = json.loads(config_path.read_text(encoding='utf-8'))
        ias = data.get('ias', {})
        enabled_dirs, root_files, has_vscode = [], [], False
        for ia in ias.values():
            if not ia.get('enabled'):
                continue
            mirror = ia.get('mirrorDir', '')
            if mirror:
                enabled_dirs.append(mirror)
            if mirror == '.vscode':
                has_vscode = True
            for f in ia.get('rootFiles', []):
                root_files.append(f)
        if not enabled_dirs:
            return default
        return {'enabled_dirs': enabled_dirs, 'root_files': root_files, 'has_vscode': has_vscode}
    except Exception as e:
        print(f'  [AVISO]    Erro ao ler config.json: {e} — usando configuração padrão')
        return default

# ---------------------------------------------------------------------------
# Operações de remoção / backup
# ---------------------------------------------------------------------------

class ResetState:
    def __init__(self, whatif: bool):
        self.whatif = whatif
        self.deleted = 0
        self.skipped = 0

def remove_if_exists(state: ResetState, path: Path, label: str) -> None:
    """Remove ficheiro ou pasta. Em WhatIf apenas reporta."""
    if path.exists() or path.is_symlink():
        if state.whatif:
            print(f'  [WhatIf]   Apagaria: {label}')
        else:
            try:
                if path.is_symlink() or path.is_file():
                    path.unlink()
                else:
                    shutil.rmtree(path)
                print(f'  [APAGADO]  {label}')
            except Exception as e:
                print(f'  [ERRO]     {label} — {e}')
                state.skipped += 1
                return
        state.deleted += 1
    else:
        if state.whatif:
            print(f'  [N/A]      {label} — não existe')
        state.skipped += 1

def move_to_backup(state: ResetState, path: Path, label: str) -> None:
    """
    Move ficheiro/pasta real para backup/{mirrorDir}/{nome}.{stamp}.
    Usado em modo rede onde mirrors são cópias reais, não symlinks.
    """
    mirror_name = path.parent.name          # ex: .claude, .vscode
    leaf        = path.name                 # ex: agents, rules
    stamp       = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_dir  = REPO_ROOT / 'backup' / mirror_name
    dest        = backup_dir / f'{leaf}.{stamp}'

    # Garantir nome único
    i = 0
    while dest.exists():
        i += 1
        dest = backup_dir / f'{leaf}.{stamp}_{i}'

    if state.whatif:
        print(f'  [WhatIf]   Moveria: {label}  ->  backup/{mirror_name}/{dest.name}')
        state.deleted += 1
        return

    backup_dir.mkdir(parents=True, exist_ok=True)
    try:
        shutil.move(str(path), str(dest))
        print(f'  [BACKUP]   {label}  ->  backup/{mirror_name}/{dest.name}')
    except Exception:
        # Fallback: copiar + remover
        try:
            if path.is_dir():
                shutil.copytree(path, dest)
            else:
                shutil.copy2(path, dest)
            try:
                if path.is_dir():
                    shutil.rmtree(path)
                else:
                    path.unlink()
            except Exception:
                pass
            print(f'  [BACKUP]   {label}  ->  backup/{mirror_name}/{dest.name} (via cópia)')
        except Exception as e2:
            print(f'  [AVISO]    {label} — não foi possível mover: {e2}')
            state.skipped += 1
            return
    state.deleted += 1

# ---------------------------------------------------------------------------
# Confirmação interativa
# ---------------------------------------------------------------------------

def confirm_reset() -> bool:
    try:
        answer = input('Confirma o reset dos ficheiros de IA? [s/N] ').strip().lower()
        return answer in ('s', 'sim', 'y', 'yes')
    except (EOFError, KeyboardInterrupt):
        return False

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    import argparse
    parser = argparse.ArgumentParser(
        description='Reset dos ficheiros de infraestrutura de IA ao estado base.'
    )
    parser.add_argument('--whatif', action='store_true',
                        help='Mostra o que seria apagado/restaurado sem alterar nada.')
    parser.add_argument('--force', action='store_true',
                        help='Não pede confirmação antes de apagar.')
    args = parser.parse_args()

    cfg     = load_mirror_config()
    network = is_network_path(REPO_ROOT)
    state   = ResetState(args.whatif)

    print()
    print('=== bootstrap-reset ===')
    print(f'    Raiz: {REPO_ROOT}')
    if args.whatif:
        print('    Modo: WhatIf (nenhum arquivo será alterado)')
    print()

    # Confirmação interativa
    if not args.force and not args.whatif:
        if not confirm_reset():
            print('Reset cancelado.')
            return 0

    # -----------------------------------------------------------------------
    # Secção 1 — Ficheiros de IA na raiz (rootFiles das IAs habilitadas)
    # -----------------------------------------------------------------------
    print('--- Ficheiros de IA (raiz) ---')
    for root_file in cfg['root_files']:
        remove_if_exists(state, REPO_ROOT / root_file, root_file)

    # -----------------------------------------------------------------------
    # Secção 2 — Configs de mirror gerados
    # -----------------------------------------------------------------------
    print()
    print('--- Configs de mirror ---')
    for mirror_dir in cfg['enabled_dirs']:
        if mirror_dir not in KNOWN_CONFIGS:
            continue
        for fname in KNOWN_CONFIGS[mirror_dir]:
            rel = f'{mirror_dir}/{fname}'
            remove_if_exists(state, REPO_ROOT / mirror_dir / fname, rel)

    # -----------------------------------------------------------------------
    # Secção 3 — Restauro de tasks.json
    #   .bak existe  -> apagar tasks.json gerado, renomear .bak -> tasks.json
    #   tasks.json ausente -> recriar do template base
    #   tasks.json existe sem .bak -> ficheiro base intacto, preservar
    # -----------------------------------------------------------------------
    print()
    print('--- Restauro tasks.json ---')

    if not cfg['has_vscode']:
        print('  [SKIP]     cursor/.vscode desabilitado no config.json')
        state.skipped += 1
    else:
        tasks_path     = REPO_ROOT / '.vscode' / 'tasks.json'
        backup_path    = REPO_ROOT / '.vscode' / 'tasks.json.bak'
        base_template  = CURSOR_DIR / 'Templates' / 'mirror-config' / 'vscode-tasks-base.template.json'

        if backup_path.exists():
            if args.whatif:
                print('  [WhatIf]   Restauraria: .vscode/tasks.json (de tasks.json.bak)')
                print('  [WhatIf]   Apagaria: .vscode/tasks.json.bak')
            else:
                if tasks_path.exists():
                    tasks_path.unlink()
                backup_path.rename(tasks_path)
                print('  [RESTAURADO] .vscode/tasks.json  <-  tasks.json.bak')
                print('  [APAGADO]    .vscode/tasks.json.bak')
            state.deleted += 2

        elif not tasks_path.exists():
            if base_template.exists():
                if args.whatif:
                    print('  [WhatIf]   Reconstruiria: .vscode/tasks.json (de vscode-tasks-base.template.json)')
                else:
                    tasks_path.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(base_template, tasks_path)
                    print('  [RECRIADO]   .vscode/tasks.json  <-  vscode-tasks-base.template.json')
                state.deleted += 1
            else:
                print('  [AVISO]    tasks.json ausente e template base não encontrado')
                state.skipped += 1
        else:
            print('  [SKIP]     tasks.json.bak ausente — tasks.json base preservado')
            state.skipped += 1

    # -----------------------------------------------------------------------
    # Secção 4 — Limpeza profunda dos mirrors
    #   Modo local: remove symlinks; remove itens reais não protegidos
    #   Modo rede:  move TUDO para backup/ (exceto protegidos)
    # -----------------------------------------------------------------------
    print()
    if network:
        print('--- Limpeza dos mirrors (tudo -> backup/, exceto protegidos) ---')
    else:
        print('--- Limpeza dos mirrors (symlinks removidos, reais eliminados) ---')

    for mirror_dir in cfg['enabled_dirs']:
        dir_path = REPO_ROOT / mirror_dir
        if not dir_path.exists():
            continue
        keep_list = PROTECTED_ITEMS.get(mirror_dir, [])

        for item in sorted(dir_path.iterdir()):
            if item.name in keep_list:
                continue
            label = f'{mirror_dir}/{item.name}'
            is_symlink = item.is_symlink()

            if is_symlink:
                # Symlink — sempre remover
                remove_if_exists(state, item, label)
            elif network:
                # Modo rede: cópia real -> backup
                move_to_backup(state, item, label)
            else:
                # Modo local: item real não-symlink (artefacto) -> remover
                remove_if_exists(state, item, f'{label} (real, não-symlink)')

    # -----------------------------------------------------------------------
    # Secção 5 — Remover pastas dos mirrors se vazias
    # -----------------------------------------------------------------------
    print()
    print('--- Pastas dos mirrors ---')

    for mirror_dir in cfg['enabled_dirs']:
        dir_path = REPO_ROOT / mirror_dir
        if not dir_path.exists():
            continue
        remaining = list(dir_path.iterdir())
        if not remaining:
            remove_if_exists(state, dir_path, f'{mirror_dir}/')
        else:
            hint = ' (tasks.json preservado)' if mirror_dir == '.vscode' else ''
            print(f'  [SKIP]     {mirror_dir}/ — contém {len(remaining)} item(s){hint}')

    # -----------------------------------------------------------------------
    # Resumo
    # -----------------------------------------------------------------------
    print()
    print('=== Resumo ===')
    if args.whatif:
        print(f'  Seriam apagados: {state.deleted} item(s)')
    else:
        print(f'  Apagados: {state.deleted} item(s)')
    print(f'  Já ausentes / preservados: {state.skipped} item(s)')
    print()

    if not args.whatif:
        print('Reset concluído.')
        if network:
            print('Execute o bootstrap para recriar cópias e configs (modo rede):')
        else:
            print('Execute o bootstrap para recriar symlinks e configs:')
        print(f'  python3 "{SCRIPT_DIR / "bootstrap_mirror_symlinks.py"}"')
        print()

    return 0


if __name__ == '__main__':
    sys.exit(main())
