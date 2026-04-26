#!/usr/bin/env python3
"""
Bootstrap dos espelhos (.claude/, .vscode/, .continue/, .opencode/) via symlinks para .cursor/.
Cross-platform: Windows, Linux, macOS.

Uso:
    python3 bootstrap_mirror_symlinks.py [--validate-only] [--repair] [--force] [--no-elevation]

Exit codes:
    0  = tudo OK (todos os symlinks/copias presentes e corretos)
    3  = symlinks em falta (ausentes, mas sem erro crítico)
    1  = erro crítico

internal_file_version: 1.0.0
Changelog:
    - 1.0.0 (09/04/2026): Versão inicial cross-platform. Equivalente ao
      bootstrap-mirror-symlinks.ps1 para Windows/Linux/macOS.
"""

import os
import sys
import json
import shutil
import platform
import argparse
import tempfile
from pathlib import Path
from datetime import datetime

# Forçar UTF-8 no console Windows para evitar garbled chars (—, ç, etc.)
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

# ---------------------------------------------------------------------------
# Constantes
# ---------------------------------------------------------------------------

OS = platform.system()  # 'Windows' | 'Linux' | 'Darwin'

# Diretórios de .cursor/ a espelhar em cada mirror
DIR_MAPPINGS = ['agents', 'commands', 'plans', 'rules', 'skills', 'Templates']

# Ficheiros de .cursor/ a espelhar
FILE_MAPPINGS = ['VERSION.md']

# README de .cursor/ → mirror/README.md
README_MAPPING = 'README.md'

# Ficheiros de config gerados a partir de templates (nunca substituídos se já existirem)
CONFIG_TEMPLATES = [
    {'template': 'vscode-settings.template.json',       'dest': '.vscode/settings.json',       'mirror': '.vscode'},
    {'template': 'vscode-extensions.template.json',     'dest': '.vscode/extensions.json',     'mirror': '.vscode'},
    {'template': 'claude-settings.template.json',       'dest': '.claude/settings.json',       'mirror': '.claude'},
    {'template': 'claude-settings-local.template.json', 'dest': '.claude/settings.local.json', 'mirror': '.claude'},
    {'template': 'claude-md.template.md',               'dest': 'CLAUDE.md',                   'mirror': '.claude'},
    {'template': 'opencode.json.template',              'dest': 'opencode.json',               'mirror': '.opencode'},
]

# ---------------------------------------------------------------------------
# Detecção de OS e rede
# ---------------------------------------------------------------------------

def is_network_path(path: Path) -> bool:
    """True se o caminho estiver numa localização de rede."""
    p = str(path)
    # Windows UNC (\\servidor\share ou //servidor/share)
    if p.startswith('\\\\') or p.startswith('//'):
        return True
    # Windows drive mapeado de rede
    if OS == 'Windows':
        try:
            import ctypes
            drive = p[:3]
            DRIVE_REMOTE = 4
            if ctypes.windll.kernel32.GetDriveTypeW(drive) == DRIVE_REMOTE:
                return True
        except Exception:
            pass
    # Linux: montagens NFS/CIFS tipicamente em /mnt/
    if OS == 'Linux' and p.startswith('/mnt/'):
        return True
    # macOS: volumes de rede tipicamente em /Volumes/
    if OS == 'Darwin' and p.startswith('/Volumes/'):
        return True
    return False

# ---------------------------------------------------------------------------
# Elevação Windows
# ---------------------------------------------------------------------------

def is_windows_admin() -> bool:
    try:
        import ctypes
        return bool(ctypes.windll.shell32.IsUserAnAdmin())
    except Exception:
        return False

def is_windows_developer_mode() -> bool:
    try:
        import winreg
        key = winreg.OpenKey(
            winreg.HKEY_LOCAL_MACHINE,
            r'SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
        )
        val, _ = winreg.QueryValueEx(key, 'AllowDevelopmentWithoutDevLicense')
        return val == 1
    except Exception:
        return False

def can_create_symlinks_windows() -> bool:
    """Verifica se consegue criar symlinks: admin OU developer mode funcional."""
    if is_windows_admin():
        return True
    if not is_windows_developer_mode():
        return False
    # Testar criação real (Developer Mode pode ser insuficiente no Windows IoT/LTSC)
    test_dir = Path(tempfile.mkdtemp())
    test_link = Path(str(test_dir) + '_link')
    try:
        os.symlink(str(test_dir), str(test_link))
        test_link.unlink()
        return True
    except OSError:
        return False
    finally:
        try:
            test_dir.rmdir()
        except Exception:
            pass

def elevate_windows(args: list[str], no_elevation: bool) -> bool:
    """Tenta reabrir o script com privilégios de Administrador via UAC.
    Retorna True se o processo filho foi lançado (este processo deve sair com 0).
    """
    if no_elevation:
        return False
    try:
        import ctypes
        import subprocess
        # Reconstrói a linha de comando
        py_exe = sys.executable
        script = str(Path(__file__).resolve())
        arg_str = f'"{script}" ' + ' '.join(f'"{a}"' for a in args)
        work_dir = str(Path(__file__).parent)
        print('\n  [INFO] Privilégios de Administrador necessários para criar symlinks.')
        print('  [INFO] A solicitar elevação (UAC) — confirme na janela do Windows.\n')
        ret = ctypes.windll.shell32.ShellExecuteW(
            None, 'runas', py_exe, arg_str, work_dir, 1
        )
        return ret > 32
    except Exception as e:
        print(f'  [AVISO] Elevação falhou: {e}')
        return False

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

def get_repo_root() -> Path:
    """scripts/ → .cursor/ → raiz do repo."""
    return Path(__file__).resolve().parent.parent.parent

def load_mirror_config(cursor_dir: Path) -> dict:
    """Lê .cursor/config.json. Retorna dict com enabled_dirs, has_vscode, has_claude, ias."""
    default = {
        'enabled_dirs': ['.claude', '.vscode', '.continue', '.opencode'],
        'has_vscode': True,
        'has_claude': True,
        'ias': {},
    }
    config_path = cursor_dir / 'config.json'
    if not config_path.exists():
        return default
    try:
        data = json.loads(config_path.read_text(encoding='utf-8'))
        ias = data.get('ias', {})
        enabled_dirs, has_vscode, has_claude = [], False, False
        for ia in ias.values():
            if not ia.get('enabled'):
                continue
            mirror = ia.get('mirrorDir', '')
            if mirror:
                enabled_dirs.append(mirror)
            if mirror == '.vscode':
                has_vscode = True
            if mirror == '.claude':
                has_claude = True
        if not enabled_dirs:
            return default
        return {
            'enabled_dirs': enabled_dirs,
            'has_vscode': has_vscode,
            'has_claude': has_claude,
            'ias': ias,
        }
    except Exception as e:
        print(f'  [AVISO]    Erro ao ler config.json: {e} — usando configuração padrão')
        return default

# ---------------------------------------------------------------------------
# Mapeamentos de symlinks
# ---------------------------------------------------------------------------

def get_symlink_mappings(repo_root: Path, cursor_dir: Path, enabled_dirs: list[str]) -> list[dict]:
    """
    Retorna lista de dicts com {source, link, type, optional}.
    type: 'dir' | 'file'
    """
    mappings = []
    for mirror_dir in enabled_dirs:
        mirror_path = repo_root / mirror_dir
        # Diretórios
        for d in DIR_MAPPINGS:
            src = cursor_dir / d
            if src.exists():
                mappings.append({
                    'source': src,
                    'link': mirror_path / d,
                    'type': 'dir',
                    'optional': False,
                })
        # Ficheiros de .cursor/
        for f in FILE_MAPPINGS:
            src = cursor_dir / f
            if src.exists():
                mappings.append({
                    'source': src,
                    'link': mirror_path / f,
                    'type': 'file',
                    'optional': True,
                })
        # README
        readme_src = cursor_dir / README_MAPPING
        if readme_src.exists():
            mappings.append({
                'source': readme_src,
                'link': mirror_path / README_MAPPING,
                'type': 'file',
                'optional': True,
            })
    return mappings

# ---------------------------------------------------------------------------
# Validação e criação de symlinks
# ---------------------------------------------------------------------------

def check_link_status(m: dict, network: bool) -> str:
    """Retorna 'ok' | 'missing' | 'conflict'."""
    link: Path = m['link']
    source: Path = m['source']
    if network:
        return 'ok' if link.exists() else 'missing'
    if link.is_symlink():
        try:
            resolved = link.resolve()
            expected = source.resolve()
            return 'ok' if resolved == expected else 'conflict'
        except Exception:
            return 'conflict'
    if link.exists():
        return 'conflict'
    return 'missing'

def validate_symlinks(mappings: list[dict], network: bool) -> tuple[list, list, list]:
    """Retorna (ok_list, missing_list, conflict_list)."""
    ok, missing, conflicts = [], [], []
    for m in mappings:
        status = check_link_status(m, network)
        if status == 'ok':
            ok.append(m)
        elif status == 'missing':
            missing.append(m)
        else:
            conflicts.append(m)
    return ok, missing, conflicts

def create_mirror_link(m: dict, network: bool, force: bool, repair: bool) -> str:
    """Cria symlink (local) ou cópia (rede). Retorna 'ok' | 'skip' | 'error:msg'."""
    source: Path = m['source']
    link: Path = m['link']
    status = check_link_status(m, network)

    if status == 'ok':
        return 'skip'

    if status == 'conflict':
        if not force and not repair:
            return f'error:conflito em {link} — use --force para substituir'
        # Backup com timestamp
        ts = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup = link.parent / f'{link.name}.{ts}'
        try:
            if link.is_symlink() or link.is_file():
                link.rename(backup)
            else:
                shutil.move(str(link), str(backup))
            print(f'  [BACKUP]   {link.relative_to(link.parent.parent)}  ->  {backup.name}')
        except Exception as e:
            return f'error:backup falhou — {e}'

    # Garantir que o diretório pai existe
    link.parent.mkdir(parents=True, exist_ok=True)

    if network:
        try:
            if source.is_dir():
                shutil.copytree(source, link, dirs_exist_ok=True)
            else:
                shutil.copy2(source, link)
            return 'ok'
        except Exception as e:
            return f'error:cópia falhou — {e}'

    # Symlink relativo — mudar para o diretório pai para que o alvo relativo
    # seja resolvido corretamente (equivalente ao Push-Location do .ps1)
    rel = os.path.relpath(source, link.parent)
    orig_cwd = os.getcwd()
    try:
        os.chdir(link.parent)
        os.symlink(rel, link.name)
        return 'ok'
    except PermissionError as e:
        return f'error:PermissionError — {e}'
    except FileExistsError:
        return 'skip'
    except Exception as e:
        return f'error:{e}'
    finally:
        os.chdir(orig_cwd)

# ---------------------------------------------------------------------------
# Templates de configuração (Install-MirrorConfigTemplate equivalente)
# ---------------------------------------------------------------------------

def install_config_templates(repo_root: Path, cursor_dir: Path, enabled_dirs: list[str]) -> None:
    """Instala settings.json, CLAUDE.md, opencode.json, etc. a partir de templates."""
    template_dir = cursor_dir / 'Templates' / 'mirror-config'
    project_name = repo_root.name
    # Tentar derivar project_name do .dpr/.lpr
    for ext in ('*.dpr', '*.lpr'):
        candidates = [p for p in repo_root.glob(ext) if '.template' not in p.name]
        if candidates:
            try:
                import re
                text = candidates[0].read_text(encoding='utf-8', errors='ignore')
                m = re.search(r'^\s*program\s+(\w+)\s*;', text, re.MULTILINE)
                if m:
                    project_name = m.group(1)
            except Exception:
                pass
            break

    # Escape de repo_root para JSON em Windows (\ → \\)
    repo_root_str = str(repo_root)
    if OS == 'Windows':
        repo_root_json = repo_root_str.replace('\\', '\\\\')
    else:
        repo_root_json = repo_root_str

    print()
    print('--- Templates de configuração ---')
    for mapping in CONFIG_TEMPLATES:
        if mapping['mirror'] not in enabled_dirs:
            continue
        dest = repo_root / mapping['dest']
        src = template_dir / mapping['template']
        label = mapping['dest']
        if dest.exists():
            print(f'  [EXISTE]   {label}  -  já existe (não substituído)')
            continue
        if not src.exists():
            print(f'  [N/A]      {label}  -  template não encontrado: {mapping["template"]}')
            continue
        dest.parent.mkdir(parents=True, exist_ok=True)
        try:
            content = src.read_text(encoding='utf-8')
            is_json = label.endswith('.json') or mapping['template'].endswith('.json.template')
            repo_sub = repo_root_json if is_json else repo_root_str
            content = content.replace('{REPO_ROOT}', repo_sub)
            content = content.replace('{PROJECT_NAME}', project_name)
            dest.write_text(content, encoding='utf-8')
            print(f'  [COPIADO]  {label}  -  inicializado a partir do template')
        except Exception as e:
            print(f'  [ERRO]     {label}  -  {e}')

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(
        description='Bootstrap dos espelhos (.claude/, .vscode/, .opencode/) via symlinks para .cursor/.'
    )
    parser.add_argument('--validate-only', action='store_true',
                        help='Verificar estado dos symlinks sem criar nem alterar nada.')
    parser.add_argument('--repair', action='store_true',
                        help='Corrigir symlinks quebrados.')
    parser.add_argument('--force', action='store_true',
                        help='Substituir conflitos com backup automático.')
    parser.add_argument('--no-elevation', action='store_true',
                        help='Não solicitar UAC (Windows).')
    parser.add_argument('--from-elevation', action='store_true',
                        help='Uso interno: indica relançamento já elevado.')
    parser.add_argument('--quiet', action='store_true',
                        help='Suprime header (usado pelo autostart para evitar saída duplicada).')
    args = parser.parse_args()

    repo_root = get_repo_root()
    cursor_dir = repo_root / '.cursor'
    cfg = load_mirror_config(cursor_dir)
    network = is_network_path(repo_root)

    mode_label = 'CÓPIA' if network else 'SYMLINK'
    if not args.quiet:
        print(f'\n=== Bootstrap Mirrors [{mode_label}] — {OS} ===')
        print(f'    Repo:   {repo_root}')
        print(f'    Mirrors: {", ".join(cfg["enabled_dirs"])}')

    mappings = get_symlink_mappings(repo_root, cursor_dir, cfg['enabled_dirs'])
    ok, missing, conflicts = validate_symlinks(mappings, network)

    # --validate-only: apenas reportar
    if args.validate_only:
        print()
        print('=== Checklist de validação ===')
        print()
        all_good = True
        for m in ok:
            lbl = m['link'].relative_to(repo_root) if m['link'].is_relative_to(repo_root) else m['link']
            print(f'  [OK]       {lbl}')
        for m in missing:
            lbl = m['link'].relative_to(repo_root) if m['link'].is_relative_to(repo_root) else m['link']
            print(f'  [AUSENTE]  {lbl}')
            all_good = False
        for m in conflicts:
            lbl = m['link'].relative_to(repo_root) if m['link'].is_relative_to(repo_root) else m['link']
            print(f'  [CONFLITO] {lbl}')
            all_good = False
        print()
        if all_good:
            print('  Todos os mirrors OK.')
            return 0
        elif missing:
            # Mirrors ausentes -> autostart deve tentar criar
            print(f'  {len(missing)} ausente(s), {len(conflicts)} conflito(s).')
            return 3
        else:
            # Apenas conflitos (pastas reais onde devia haver symlink) ->
            # mirrors existem e são funcionais; não bloquear o autostart
            print(f'  {len(conflicts)} conflito(s) — use --repair ou --force para converter em symlinks.')
            return 0

    # Modo criação/reparação
    # Windows local sem admin: tentar elevação
    if OS == 'Windows' and not network and not can_create_symlinks_windows():
        if not args.from_elevation:
            forward_args = []
            if args.repair:
                forward_args.append('--repair')
            if args.force:
                forward_args.append('--force')
            if args.no_elevation:
                forward_args.append('--no-elevation')
            forward_args.append('--from-elevation')
            launched = elevate_windows(forward_args, args.no_elevation)
            if launched:
                return 0  # processo filho vai fazer o trabalho
        # Elevação falhou ou --no-elevation
        print('\n  ============================================================')
        print('  ERRO: Sem privilégios para criar symlinks.')
        print('  ============================================================')
        print()
        print('  Opções:')
        print('    1. Executar como Administrador (botão direito → Executar como administrador)')
        print('    2. Ativar Modo Programador do Windows')
        print('       (Definições → Privacidade e segurança → Para programadores)')
        print()
        return 1

    # Criar/reparar
    print()
    print('--- Criando mirrors ---')
    errors = 0
    created = 0
    skipped = 0

    targets = missing + (conflicts if (args.repair or args.force) else [])
    for m in targets:
        result = create_mirror_link(m, network, args.force, args.repair)
        lbl = m['link'].relative_to(repo_root) if m['link'].is_relative_to(repo_root) else m['link']
        if result == 'ok':
            verb = 'CÓPIA' if network else 'CRIADO'
            print(f'  [{verb}]   {lbl}')
            created += 1
        elif result == 'skip':
            print(f'  [SKIP]     {lbl}')
            skipped += 1
        else:
            msg = result.removeprefix('error:')
            print(f'  [ERRO]     {lbl}  —  {msg}')
            if 'PermissionError' in result and OS != 'Windows':
                print()
                print('  DICA: Execute com sudo:')
                print(f'    sudo python3 "{Path(__file__)}" {" ".join(sys.argv[1:])}')
                print()
            errors += 1

    # Conflitos não tratados
    if not args.repair and not args.force:
        for m in conflicts:
            lbl = m['link'].relative_to(repo_root) if m['link'].is_relative_to(repo_root) else m['link']
            print(f'  [CONFLITO] {lbl}  —  use --repair ou --force para corrigir')

    # Instalar templates de config (settings.json, CLAUDE.md, etc.)
    if created > 0 or skipped > 0:
        install_config_templates(repo_root, cursor_dir, cfg['enabled_dirs'])

    print()
    print(f'  Resultado: {created} criado(s), {skipped} já OK, {errors} erro(s).')
    print()

    if errors > 0:
        return 1
    if len(missing) > 0 and created == 0:
        return 3
    return 0


if __name__ == '__main__':
    sys.exit(main())
