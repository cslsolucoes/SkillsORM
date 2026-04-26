#!/usr/bin/env python3
"""
Auto-start do bootstrap de espelhos — executado automaticamente ao abrir a pasta.
Cross-platform: Windows, Linux, macOS.

Equivalente ao bootstrap-autostart-mirrors.ps1.

Lógica:
    1) Executa validação (--validate-only) — não precisa de admin.
    2) Exit 0: tudo OK — instala tasks.json e ignore files; termina silenciosamente.
    3) Exit 3: symlinks em falta — tenta criar (bootstrap completo).
       Se falhar por falta de privilégios: mostra instrução e sai com 0
       (não falha a task — apenas avisa o utilizador).
    4) Outros exit codes: propaga o erro.

internal_file_version: 1.2.0
Changelog:
    - 1.2.0 (12/04/2026): install_tasks_template — removida detecção de nome de projeto e substituição
      de placeholders {PROJECT_NAME}, {PROJECT_DPR}, {FPC_ROOT}; template vscode-tasks.template.json
      usa variáveis nativas do VSCode (${workspaceFolderBasename}, ${workspaceFolder}, ${env:FPC_ROOT})
      resolvidas pelo editor em tempo de execução. Paridade com bootstrap-autostart-mirrors.ps1 1.0.8.
    - 1.1.0 (11/04/2026): Nomenclatura canónica `bootstrap_autostart_mirrors.py` (prefixo bootstrap_*).
    - 1.0.0 (09/04/2026): Versão inicial cross-platform; paridade com bootstrap-autostart-mirrors.ps1 (Windows/Linux/macOS).
"""

import os
import sys
import json
import re
import subprocess
import platform
from pathlib import Path

# Forçar UTF-8 no console Windows
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

OS = platform.system()  # 'Windows' | 'Linux' | 'Darwin'

# ---------------------------------------------------------------------------
# Caminhos
# ---------------------------------------------------------------------------

SCRIPT_DIR  = Path(__file__).resolve().parent          # .cursor/scripts/
CURSOR_DIR  = SCRIPT_DIR.parent                        # .cursor/
REPO_ROOT   = CURSOR_DIR.parent                        # raiz do repo
SYMLINKS_PY = SCRIPT_DIR / 'bootstrap_mirror_symlinks.py'

# ---------------------------------------------------------------------------
# Helpers (duplicados de bootstrap_mirror_symlinks para ser auto-contido)
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

def load_mirror_config() -> dict:
    config_path = CURSOR_DIR / 'config.json'
    default = {
        'enabled_dirs': ['.claude', '.vscode', '.continue', '.opencode'],
        'has_vscode': True,
        'has_claude': True,
        'ias': {},
    }
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
        return {'enabled_dirs': enabled_dirs, 'has_vscode': has_vscode,
                'has_claude': has_claude, 'ias': ias}
    except Exception as e:
        print(f'  [AVISO]    Erro ao ler config.json: {e}')
        return default

def detect_project_name() -> str:
    """Tenta derivar o nome do projeto do .dpr/.lpr na raiz. Fallback: nome da pasta."""
    project_name = REPO_ROOT.name
    for ext in ('*.dpr', '*.lpr'):
        candidates = [p for p in REPO_ROOT.glob(ext) if '.template' not in p.name]
        if candidates:
            try:
                text = candidates[0].read_text(encoding='utf-8', errors='ignore')
                m = re.search(r'^\s*program\s+(\w+)\s*;', text, re.MULTILINE)
                if m:
                    project_name = m.group(1)
            except Exception:
                pass
            break
    return project_name

def has_project_files() -> bool:
    """True se existe .dpr ou .lpr na raiz (excluindo templates)."""
    for ext in ('*.dpr', '*.lpr'):
        if any(True for p in REPO_ROOT.glob(ext) if '.template' not in p.name):
            return True
    return False

# ---------------------------------------------------------------------------
# Install-TasksTemplate equivalente
# ---------------------------------------------------------------------------

def install_tasks_template() -> None:
    """
    Faz backup de .vscode/tasks.json e instala o template.
    O template usa variáveis nativas do VSCode (${workspaceFolderBasename},
    ${workspaceFolder}, ${env:FPC_ROOT}) — nenhuma substituição necessária.
    Executa apenas uma vez (detectado pelo .bak).
    """
    tasks_path    = REPO_ROOT / '.vscode' / 'tasks.json'
    backup_path   = REPO_ROOT / '.vscode' / 'tasks.json.bak'
    template_path = CURSOR_DIR / 'Templates' / 'mirror-config' / 'vscode-tasks.template.json'

    # Já instalado numa sessão anterior
    if backup_path.exists():
        return

    if not template_path.exists():
        print('  [AVISO]    vscode-tasks.template.json não encontrado — tasks.json não atualizado.')
        return

    # Backup do ficheiro base
    if tasks_path.exists():
        import shutil
        shutil.copy2(tasks_path, backup_path)
        print('  [BACKUP]   .vscode/tasks.json  ->  tasks.json.bak')

    # Ler template e remover apenas a linha _template_info do JSON.
    # Todas as variáveis (${workspaceFolderBasename}, ${workspaceFolder},
    # ${env:FPC_ROOT}) são resolvidas pelo próprio VSCode em tempo de execução.
    content = template_path.read_text(encoding='utf-8')
    lines = [l for l in content.splitlines(keepends=True) if '"_template_info"' not in l]
    content = ''.join(lines)

    tasks_path.parent.mkdir(parents=True, exist_ok=True)
    tasks_path.write_text(content, encoding='utf-8')
    print('  [COPIADO]  .vscode/tasks.json  <-  vscode-tasks.template.json')

# ---------------------------------------------------------------------------
# Install-IgnoreFiles equivalente
# ---------------------------------------------------------------------------

def install_ignore_files(cfg: dict) -> None:
    """
    Cria ficheiros *ignore na raiz para cada IA habilitada que tenha
    ignoreTemplate definido. Não sobrescreve se já existir.
    """
    project_name = detect_project_name()
    template_dir = CURSOR_DIR / 'Templates' / 'mirror-config'

    for ia in cfg['ias'].values():
        if not ia.get('enabled'):
            continue
        ignore_template = ia.get('ignoreTemplate', '')
        ignore_file     = ia.get('ignoreFile', '')
        if not ignore_template or not ignore_file:
            continue

        dest_path     = REPO_ROOT / ignore_file
        template_path = template_dir / ignore_template

        # Já existe — preservar customizações do utilizador
        if dest_path.exists():
            continue

        if not template_path.exists():
            print(f'  [AVISO]    Template {ignore_template} não encontrado — {ignore_file} não criado.')
            continue

        try:
            content = template_path.read_text(encoding='utf-8')
            content = content.replace('{PROJECT_NAME}', project_name)
            dest_path.write_text(content, encoding='utf-8')
            print(f'  [CRIADO]   {ignore_file}  <-  {ignore_template}  (projeto: {project_name})')
        except Exception as e:
            print(f'  [ERRO]     {ignore_file}  —  {e}')

# ---------------------------------------------------------------------------
# Substituição de tokens {NOME_PROJETO} no pack .cursor/ local
# ---------------------------------------------------------------------------

_TOKEN_RE = re.compile(r'\{NOME_PROJETO\}')

def apply_project_tokens() -> None:
    """
    Substitui {NOME_PROJETO} pelo nome do projeto em todos os .md/.mdc do .cursor/.
    Executado após bootstrap para garantir que o pack local reflita o nome correto.
    Idempotente — se não há tokens, não altera nada.
    """
    project_name = detect_project_name()
    changed = 0
    for path in CURSOR_DIR.rglob('*'):
        if path.suffix not in ('.md', '.mdc') or not path.is_file():
            continue
        try:
            content = path.read_text(encoding='utf-8', errors='replace')
        except Exception:
            continue
        if '{NOME_PROJETO}' not in content:
            continue
        new_content = _TOKEN_RE.sub(project_name, content)
        try:
            path.write_text(new_content, encoding='utf-8')
            changed += 1
        except Exception:
            pass
    if changed:
        print(f'  [TOKENS]   {{NOME_PROJETO}} → "{project_name}" em {changed} arquivo(s)')

# ---------------------------------------------------------------------------
# Mensagens de erro por OS
# ---------------------------------------------------------------------------

def print_error_local(cfg: dict, network: bool) -> None:
    if network:
        print()
        print('  ============================================================')
        print('  [AUTO-START] ERRO AO CRIAR CÓPIAS (modo rede)')
        print('  ============================================================')
        print()
        print('  Execute o bootstrap manualmente para ver o erro:')
        print(f'    python3 "{SYMLINKS_PY}"')
        print()
    else:
        mirror_list = '  '.join(f'{d}/' for d in cfg['enabled_dirs'])
        print()
        print('  ============================================================')
        print('  [AUTO-START] CONFIGURAÇÃO INICIAL NECESSÁRIA (uma única vez)')
        print('  ============================================================')
        print()
        print(f'  Os espelhos ({mirror_list}) não existem.')
        print()
        if OS == 'Windows':
            print('  OPÇÃO 1 — Reabrir o Cursor como Admin (recomendado):')
            print('    1. Fechar o Cursor.')
            print('    2. Botão direito no ícone > Executar como administrador.')
            print('    3. Abrir esta pasta — o auto-start criará os symlinks.')
            print()
            print('  OPÇÃO 2 — Terminal > Executar Tarefa:')
            print('    "Mirror Bootstrap: Full Run"')
            print()
        else:
            # Linux / macOS
            print('  Execute com sudo:')
            print(f'    sudo python3 "{SYMLINKS_PY}"')
            print()
        print('  Após criados, o auto-start funcionará sem privilégios especiais nas próximas sessões.')
        print()

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    if not SYMLINKS_PY.exists():
        print(f'  [ERRO]  Script não encontrado: {SYMLINKS_PY}')
        return 1

    cfg     = load_mirror_config()
    network = is_network_path(REPO_ROOT)

    # -----------------------------------------------------------------------
    # Passo 1: Validação (sem admin necessário)
    # -----------------------------------------------------------------------
    result = subprocess.run(
        [sys.executable, str(SYMLINKS_PY), '--validate-only', '--quiet'],
        capture_output=False
    )
    validate_code = result.returncode

    if validate_code == 0:
        # Tudo OK
        print()
        print('  [AUTO-START] Espelhos OK.')

        if cfg['has_vscode']:
            install_tasks_template()

        install_ignore_files(cfg)
        apply_project_tokens()

        if not has_project_files():
            print()
            print('  ============================================================')
            print('  [PROJETO] Nenhum projeto encontrado na raiz.')
            print('  ============================================================')
            print()
            print('  >>> Abra o chat do Cursor (Ctrl+L) e escreva:')
            print()
            print('        /init')
            print()
            print('  O assistente irá perguntar o nome do projeto e criar')
            print('  automaticamente todos os arquivos necessários.')
            print('  ============================================================')
            print()

        return 0

    if validate_code == 3:
        action_label = 'cópias' if network else 'symlinks'
        print()
        print(f'  [AUTO-START] Espelhos em falta — a tentar criação de {action_label}...')
        print()

        result2 = subprocess.run(
            [sys.executable, str(SYMLINKS_PY)],
            capture_output=False
        )
        create_code = result2.returncode

        if create_code == 0:
            success_label = 'Cópias criadas' if network else 'Symlinks criados'
            print()
            print(f'  [AUTO-START] {success_label} com sucesso.')
            print()

            if cfg['has_vscode']:
                install_tasks_template()

            install_ignore_files(cfg)
            apply_project_tokens()
            return 0

        # Criação falhou
        print_error_local(cfg, network)
        return 0  # Não falha a task — apenas avisa o utilizador

    # Exit code inesperado — propaga
    print()
    print(f'  [AUTO-START] Erro no bootstrap (exit code: {validate_code}).')
    print()
    return validate_code


if __name__ == '__main__':
    sys.exit(main())
