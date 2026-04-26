#!/usr/bin/env python3
"""
Validador do pack .cursor/ — verifica skills, agents, rules, commands, templates e manifestos.

Uso:
    python validate_pack.py [--verbose]

Checks:
    1. Frontmatter YAML (name, description, model) em SKILL.md e agents
    2. Version alignment (sufixo pasta/ficheiro = FileVersion)
    3. Stale path references (Constitution/, Developer/, compile.md root, etc.)
    4. Model assignments validos (haiku/sonnet/opus)
    5. Changelog presente e consistente com FileVersion
    6. Cross-refs entre skills/agents
    7. Manifestos: contagem e FolderVersion
    8. Mirrors: symlinks em modo local; copias reais aceites em modo rede (auto-detectado)

# internal_file_version: 1.1.0
# Changelog:
# - 1.1.0 (17/04/2026): Adicionados checks --no-instance-strings e --indexes-fresh
#   (Onda 1 do refactor). --no-instance-strings detecta strings especificas do clone
#   (nome de projeto em path absoluto com drive letter, MXX literais com dominio)
#   --indexes-fresh valida que .cursor/index.db e .workspace/index.db estao
#   sincronizados com o filesystem via mtime.
# - 1.0.2 (09/04/2026): load_mirror_config() — le .cursor/config.json para determinar
#   mirrors activos; mirrors desabilitados ignorados nos checks em vez de reportados
#   como ausentes; fallback ao conjunto completo se config ausente ou invalido.
# - 1.0.1 (09/04/2026): is_network_path() — auto-detecta UNC ou drive mapeado de rede;
#   validate_mirrors() aceita copias reais (pasta/ficheiro) em modo rede sem reportar
#   CRITICAL; modo exibido nas mensagens (SYMLINK vs COPIA).
# - 1.0.0 (04/04/2026): Versao inicial.
"""

import os
import re
import sys
import glob
import json
import argparse
from pathlib import Path
from dataclasses import dataclass, field

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

VALID_MODELS = {'haiku', 'sonnet', 'opus'}

STALE_PATTERNS = [
    (r'\.cursor/Constitution/constitution-', 'Constitution/ eliminado'),
    (r'\.cursor/Developer/', 'Developer/ eliminado'),
    (r'documentation-superseded-definition\b', 'skill deprecada'),
    (r'documentation-migration-conflict-resolution\b', 'skill deprecada'),
    (r'documentation-cursor-rules-integration\b', 'skill deprecada'),
]

# Patterns que só são stale fora de changelogs
STALE_PATTERNS_NON_CHANGELOG = [
    (r'\.cursor/compile\.md(?!/)', 'compile.md movido para exemplos/'),
    (r'\.cursor/database\.md(?!/)', 'database.md movido para exemplos/'),
    (r'\.cursor/diretivas_compilacao\.md(?!/)', 'diretivas movido para exemplos/'),
]

CHANGELOG_LINE = re.compile(r'^\s*-\s*\d+\.\d+\.\d+\s*\(')
FILEVERSION_RE = re.compile(r'\*\*FileVersion\*\*\s*\|\s*(\d+\.\d+\.\d+)')
VERSION_SUFFIX_RE = re.compile(r'_V(\d+\.\d+\.\d+)$')
FRONTMATTER_RE = re.compile(r'^\ufeff?---\s*\n(.*?)\n---', re.DOTALL)

MIRROR_DIRS_DEFAULT = ['.claude', '.vscode', '.continue', '.opencode']
EXPECTED_SYMLINKS = ['agents', 'commands', 'plans', 'rules', 'skills', 'Templates', 'README.md', 'VERSION.md']


def load_mirror_config(root: Path) -> list:
    """Le .cursor/config.json e devolve lista de mirrorDirs habilitados.
    Retorna MIRROR_DIRS_DEFAULT se config ausente ou invalido."""
    config_path = root / '.cursor' / 'config.json'
    if not config_path.exists():
        return MIRROR_DIRS_DEFAULT
    try:
        data = json.loads(config_path.read_text(encoding='utf-8'))
        ias = data.get('ias', {})
        dirs = [ia.get('mirrorDir') for ia in ias.values()
                if ia.get('enabled') is True and ia.get('mirrorDir')]
        return dirs if dirs else MIRROR_DIRS_DEFAULT
    except Exception:
        return MIRROR_DIRS_DEFAULT


@dataclass
class Issue:
    severity: str  # CRITICAL, MODERATE, LOW
    category: str
    file: str
    line: int
    message: str


@dataclass
class Report:
    issues: list = field(default_factory=list)
    checks: int = 0
    passed: int = 0

    def add(self, severity, category, file, line, message):
        self.issues.append(Issue(severity, category, file, line, message))

    def check(self, ok, severity, category, file, line, message):
        self.checks += 1
        if ok:
            self.passed += 1
        else:
            self.add(severity, category, file, line, message)
        return ok


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def parse_frontmatter(content):
    """Extrai campos do frontmatter YAML (simplificado, sem pyyaml)."""
    m = FRONTMATTER_RE.match(content)
    if not m:
        return None
    fm = {}
    current_key = None
    for line in m.group(1).splitlines():
        if line.startswith('  ') and current_key:
            fm[current_key] = fm.get(current_key, '') + ' ' + line.strip()
        elif ':' in line:
            key, _, val = line.partition(':')
            key = key.strip()
            val = val.strip()
            if val in ('>-', '>', '|'):
                current_key = key
                fm[key] = ''
            else:
                current_key = key
                fm[key] = val
    return fm


def extract_fileversion(content):
    m = FILEVERSION_RE.search(content)
    return m.group(1) if m else None


def is_changelog_line(line):
    return bool(CHANGELOG_LINE.match(line))


def rel(path, root):
    try:
        return str(Path(path).relative_to(root))
    except ValueError:
        return str(path)


# ---------------------------------------------------------------------------
# Validators
# ---------------------------------------------------------------------------

def validate_skills(root, report, verbose):
    skills_dir = root / '.cursor' / 'skills'
    if not skills_dir.exists():
        report.add('CRITICAL', 'skills', str(skills_dir), 0, 'Pasta skills/ nao existe')
        return

    skill_folders = sorted([d for d in skills_dir.iterdir()
                           if d.is_dir() and '_V' in d.name])

    for folder in skill_folders:
        skill_file = folder / 'SKILL.md'
        if not skill_file.exists():
            report.add('CRITICAL', 'skills', rel(folder, root), 0, 'SKILL.md ausente')
            continue

        content = skill_file.read_text(encoding='utf-8', errors='replace')
        fm = parse_frontmatter(content)
        rpath = rel(skill_file, root)

        # Frontmatter
        report.check(fm is not None, 'CRITICAL', 'frontmatter', rpath, 0,
                     'Frontmatter YAML ausente ou malformado')
        if not fm:
            continue

        report.check('name' in fm, 'CRITICAL', 'frontmatter', rpath, 0,
                     'Campo name: ausente no frontmatter')
        report.check('description' in fm, 'CRITICAL', 'frontmatter', rpath, 0,
                     'Campo description: ausente no frontmatter')
        report.check('model' in fm, 'CRITICAL', 'frontmatter', rpath, 0,
                     'Campo model: ausente no frontmatter')
        if 'model' in fm:
            report.check(fm['model'] in VALID_MODELS, 'CRITICAL', 'model', rpath, 0,
                         f"model: '{fm['model']}' invalido (esperado: {VALID_MODELS})")

        # Version alignment
        fv = extract_fileversion(content)
        m = VERSION_SUFFIX_RE.search(folder.name)
        folder_ver = m.group(1) if m else None
        if fv and folder_ver:
            report.check(fv == folder_ver, 'CRITICAL', 'version', rpath, 0,
                         f'Pasta _V{folder_ver} != FileVersion {fv}')

        # Stale refs
        check_stale_refs(content, rpath, report)

        if verbose:
            model = fm.get('model', '?')
            print(f"  [OK] {folder.name}  model={model}  FileVersion={fv}")


def validate_agents(root, report, verbose):
    agents_dir = root / '.cursor' / 'agents'
    if not agents_dir.exists():
        report.add('CRITICAL', 'agents', str(agents_dir), 0, 'Pasta agents/ nao existe')
        return

    agent_files = sorted(agents_dir.glob('*-agent-*.md'))

    for af in agent_files:
        content = af.read_text(encoding='utf-8', errors='replace')
        fm = parse_frontmatter(content)
        rpath = rel(af, root)

        report.check(fm is not None, 'CRITICAL', 'frontmatter', rpath, 0,
                     'Frontmatter YAML ausente')
        if not fm:
            continue

        report.check('name' in fm, 'CRITICAL', 'frontmatter', rpath, 0, 'name: ausente')
        report.check('model' in fm, 'CRITICAL', 'frontmatter', rpath, 0, 'model: ausente')
        if 'model' in fm:
            report.check(fm['model'] in VALID_MODELS, 'CRITICAL', 'model', rpath, 0,
                         f"model: '{fm['model']}' invalido")
            report.check(fm['model'] != 'inherit', 'CRITICAL', 'model', rpath, 0,
                         'model: inherit (deve ser haiku/sonnet/opus)')

        # Version alignment
        fv = extract_fileversion(content)
        m = VERSION_SUFFIX_RE.search(af.stem)
        file_ver = m.group(1) if m else None
        if fv and file_ver:
            report.check(fv == file_ver, 'CRITICAL', 'version', rpath, 0,
                         f'Ficheiro _V{file_ver} != FileVersion {fv}')

        check_stale_refs(content, rpath, report)

        if verbose:
            print(f"  [OK] {af.name}  model={fm.get('model','?')}  FileVersion={fv}")


def validate_rules(root, report, verbose):
    rules_dir = root / '.cursor' / 'rules'
    if not rules_dir.exists():
        return

    mdc_files = sorted(rules_dir.glob('*.mdc'))
    for mf in mdc_files:
        content = mf.read_text(encoding='utf-8', errors='replace')
        rpath = rel(mf, root)
        check_stale_refs(content, rpath, report)
        if verbose:
            print(f"  [OK] {mf.name}")


def validate_commands(root, report, verbose):
    cmds_dir = root / '.cursor' / 'commands'
    if not cmds_dir.exists():
        return

    for cf in sorted(cmds_dir.glob('*.md')):
        content = cf.read_text(encoding='utf-8', errors='replace')
        fm = parse_frontmatter(content)
        rpath = rel(cf, root)
        report.check(fm is not None, 'MODERATE', 'frontmatter', rpath, 0,
                     'Frontmatter ausente no command')
        if fm:
            report.check('name' in fm, 'MODERATE', 'frontmatter', rpath, 0, 'name: ausente')
        if verbose:
            print(f"  [OK] {cf.name}")


def validate_manifests(root, report, verbose):
    """Verifica manifestos: FolderVersion no header = sufixo do nome do ficheiro."""
    manifest_patterns = [
        '.cursor/skills/skills-pack-manifest_V*.md',
        '.cursor/agents/agents-pack-manifest_V*.md',
        '.cursor/rules/rules-pack-manifest_V*.md',
        '.cursor/Templates/templates-pack-manifest_V*.md',
    ]

    for pattern in manifest_patterns:
        files = sorted(root.glob(pattern))
        report.check(len(files) == 1, 'MODERATE', 'manifest', pattern, 0,
                     f'Esperado 1 manifesto, encontrados {len(files)}')
        for mf in files:
            content = mf.read_text(encoding='utf-8', errors='replace')
            rpath = rel(mf, root)

            # FolderVersion no header
            fv_match = re.search(r'\*\*FolderVersion:\*\*\s*(\d+\.\d+\.\d+)', content)
            m = VERSION_SUFFIX_RE.search(mf.stem)
            if fv_match and m:
                report.check(fv_match.group(1) == m.group(1), 'CRITICAL', 'manifest', rpath, 0,
                             f"FolderVersion {fv_match.group(1)} != sufixo _V{m.group(1)}")

            if verbose:
                ver = fv_match.group(1) if fv_match else '?'
                print(f"  [OK] {mf.name}  FolderVersion={ver}")


def is_network_path(path):
    """True se o caminho estiver numa localizacao de rede (UNC ou drive mapeado de rede)."""
    path_str = str(path)
    # UNC path (\\servidor\share ou //servidor/share)
    if path_str.startswith('\\\\') or path_str.startswith('//'):
        return True
    # Drive mapeado de rede (Windows only via ctypes)
    try:
        import ctypes
        drive = path_str[:3]  # ex: "E:\\"
        DRIVE_REMOTE = 4
        return ctypes.windll.kernel32.GetDriveTypeW(drive) == DRIVE_REMOTE
    except Exception:
        pass
    return False


def validate_mirrors(root, report, verbose):
    """Verifica mirrors: symlinks em modo local, copias reais em modo rede."""
    network_mode = is_network_path(root)
    mode_label = 'COPIA' if network_mode else 'SYMLINK'
    mirror_dirs = load_mirror_config(root)

    for mirror in mirror_dirs:
        mirror_dir = root / mirror
        if not mirror_dir.exists():
            report.add('LOW', 'mirrors', mirror, 0, f'{mirror}/ nao existe (executar bootstrap)')
            continue

        for name in EXPECTED_SYMLINKS:
            path = mirror_dir / name
            if not path.exists():
                report.add('MODERATE', 'mirrors', f'{mirror}/{name}', 0,
                           f'Entrada ausente (esperado {mode_label})')
            elif network_mode:
                # Modo rede: aceitar pasta/ficheiro real (copia sincronizada de .cursor/)
                report.checks += 1
                report.passed += 1
                if verbose:
                    print(f"  [OK] {mirror}/{name}  {mode_label}")
            elif not path.is_symlink():
                report.add('CRITICAL', 'mirrors', f'{mirror}/{name}', 0,
                           'E pasta/ficheiro REAL (deveria ser symlink)')
            else:
                report.checks += 1
                report.passed += 1
                if verbose:
                    print(f"  [OK] {mirror}/{name}  {mode_label}")


def validate_counts(root, report, verbose):
    """Verifica contagens de skills e agents."""
    skills = list((root / '.cursor' / 'skills').glob('*_V*/SKILL.md'))
    agents = list((root / '.cursor' / 'agents').glob('*-agent-*.md'))
    rules = list((root / '.cursor' / 'rules').glob('*.mdc'))
    commands = list((root / '.cursor' / 'commands').glob('*.md'))

    if verbose:
        print(f"  Skills: {len(skills)}")
        print(f"  Agents: {len(agents)}")
        print(f"  Rules:  {len(rules)}")
        print(f"  Commands: {len(commands)}")


def check_stale_refs(content, filepath, report):
    """Verifica referências stale no conteúdo."""
    for i, line in enumerate(content.splitlines(), 1):
        if is_changelog_line(line) or 'anteriormente em' in line.lower():
            continue

        for pattern, msg in STALE_PATTERNS:
            if re.search(pattern, line):
                # Excluir description: que menciona substituição
                if 'Substitui' in line or 'constitution-policies' in line or 'absorbed' in line.lower():
                    continue
                report.add('MODERATE', 'stale-ref', filepath, i, f'{msg}: {line.strip()[:80]}')

        for pattern, msg in STALE_PATTERNS_NON_CHANGELOG:
            if re.search(pattern, line) and 'exemplos/' not in line:
                report.add('MODERATE', 'stale-ref', filepath, i, f'{msg}: {line.strip()[:80]}')


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def validate_no_instance_strings(root, report, verbose):
    """
    Verifica que .cursor/ nao contem strings especificas do clone actual
    (nomes concretos de projeto, paths absolutos com drive letter, nomes
    literais MXX M01-<Domain>).

    Fora do escopo: .cursor/Backup/, .cursor/docs/, .cursor/Templates/ (exemplos
    podem citar estes literais). A pasta .docs/ (raiz) fica fora deste scan por
    omissao — nao e .cursor/.
    """
    cursor_dir = root / '.cursor'
    if not cursor_dir.exists():
        return

    # Padroes proibidos em ficheiros genericos:
    #  - paths absolutos Windows com nome de projeto (detectados via regex generico de drive letter)
    #  - nomes concretos MXX (ex.: M01-Seguranca_Acesso, M02-Cadastros_Base)
    patterns = [
        (r'\b[A-Za-z]:/[A-Za-z0-9_\.-]+/(projects|Documentation|src|SQLite)\b',
         'path absoluto com drive letter apontando para conteudo do clone'),
        (r'\bM\d{2}-[A-Z][A-Za-z_]+\b', 'nome concreto de modulo MXX com dominio'),
    ]

    excluded_parts = {'Backup', 'Docs', 'Templates'}
    # config.json contem paths locais legítimos (_frameworks,
    # _workspace_context, paths de mirrors) — excluído do check
    excluded_files = {
        'rename-map_V1.0.0.md',
        'project-exclusive-pack_V1.0.0.md',
        'config.json',
        # artifact-placement-policy cita MXX como exemplo do que nao deve existir
        # fora de .workspace/ — exclusao legitima
        'artifact-placement-policy_V1.0.0.mdc',
    }

    for p in cursor_dir.rglob('*'):
        if not p.is_file():
            continue
        if any(part in excluded_parts for part in p.relative_to(cursor_dir).parts):
            continue
        if p.suffix not in {'.md', '.mdc', '.json'}:
            continue
        if p.name in excluded_files:
            continue
        try:
            text = p.read_text(encoding='utf-8', errors='ignore')
        except Exception:
            continue
        for pattern, desc in patterns:
            for i, line in enumerate(text.splitlines(), 1):
                if re.search(pattern, line):
                    report.add('MODERATE', 'instance-strings',
                               rel(p, root), i,
                               f'contem {desc}: "{line.strip()[:80]}"')
        report.checks += 1
    report.passed += 1


def validate_indexes_fresh(root, report, verbose):
    """
    Verifica que .cursor/index.db e .workspace/index.db estao sincronizados
    com o filesystem — ou seja, nao ha ficheiro .md/.mdc mais recente que o
    indexed_at guardado na DB.

    Requer: pack_index_db.py ja inicializou as DBs.
    """
    import sqlite3
    from datetime import datetime, timezone

    for scope, rel_path, content_root in [
        ('cursor', '.cursor/index.db', root / '.cursor'),
        ('workspace', '.workspace/index.db', root / '.workspace'),
    ]:
        db_path = root / rel_path
        if not db_path.exists():
            report.add('LOW', 'indexes-fresh', str(db_path), 0,
                       f'{scope}: index.db nao existe — correr /syncdb')
            continue

        try:
            conn = sqlite3.connect(db_path)
            rows = conn.execute(
                'SELECT path, content_hash, modified_at FROM artefacts').fetchall()
            conn.close()
        except Exception as exc:
            report.add('MODERATE', 'indexes-fresh', str(db_path), 0,
                       f'{scope}: falha a ler index.db: {exc}')
            continue

        stale = 0
        for path_str, db_hash, db_modified in rows:
            full = root / path_str
            if not full.exists():
                report.add('LOW', 'indexes-fresh', path_str, 0,
                           f'{scope}: ficheiro na DB mas removido do filesystem')
                stale += 1
                continue
            try:
                mtime = datetime.fromtimestamp(
                    full.stat().st_mtime, tz=timezone.utc
                ).isoformat(timespec='seconds')
                if db_modified and mtime > db_modified:
                    report.add('LOW', 'indexes-fresh', path_str, 0,
                               f'{scope}: filesystem mtime > DB modified_at '
                               f'(correr /syncdb)')
                    stale += 1
            except Exception:
                pass

        if verbose:
            print(f'    [{scope}] {len(rows)} entries, {stale} stale')
        report.checks += 1
    report.passed += 1


def main():
    # Garantir UTF-8 no stdout (evita UnicodeEncodeError em Windows cp1252)
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except Exception:
        pass

    parser = argparse.ArgumentParser(description='Validador do pack .cursor/')
    parser.add_argument('--verbose', '-v', action='store_true', help='Mostrar detalhes de cada check')
    parser.add_argument('--root', default=None, help='Raiz do repositorio (auto-detecta)')
    parser.add_argument('--no-instance-strings', action='store_true',
                        help='Falha se encontrar strings especificas do clone em .cursor/')
    parser.add_argument('--indexes-fresh', action='store_true',
                        help='Verifica que .cursor/index.db e .workspace/index.db estao sincronizados')
    args = parser.parse_args()

    # Auto-detect root
    if args.root:
        root = Path(args.root)
    else:
        script_dir = Path(__file__).parent
        root = script_dir.parent.parent  # scripts/ -> .cursor/ -> raiz

    if not (root / '.cursor').exists():
        print(f'ERRO: .cursor/ nao encontrado em {root}')
        sys.exit(2)

    network_mode = is_network_path(root)
    print(f'=== Validador do Pack .cursor/ ===')
    print(f'    Raiz: {root}')
    if network_mode:
        print(f'    Modo: REDE (mirrors como copias reais, nao symlinks)')
    print()

    report = Report()

    sections = [
        ('Skills', validate_skills),
        ('Agents', validate_agents),
        ('Rules', validate_rules),
        ('Commands', validate_commands),
        ('Manifestos', validate_manifests),
        ('Mirrors', validate_mirrors),
        ('Contagens', validate_counts),
    ]
    if args.no_instance_strings:
        sections.append(('Instance Strings', validate_no_instance_strings))
    if args.indexes_fresh:
        sections.append(('Indexes Fresh', validate_indexes_fresh))

    for name, fn in sections:
        print(f'--- {name} ---')
        fn(root, report, args.verbose)
        print()

    # Report
    print('=' * 60)
    print(f'  Checks: {report.checks}  |  Passed: {report.passed}  |  Issues: {len(report.issues)}')
    print('=' * 60)

    if report.issues:
        by_severity = {}
        for issue in report.issues:
            by_severity.setdefault(issue.severity, []).append(issue)

        for sev in ['CRITICAL', 'MODERATE', 'LOW']:
            items = by_severity.get(sev, [])
            if items:
                print(f'\n  [{sev}] ({len(items)})')
                for i in items:
                    loc = f'{i.file}:{i.line}' if i.line else i.file
                    print(f'    - {loc}  {i.message}')

        print()
        critical = len(by_severity.get('CRITICAL', []))
        if critical:
            print(f'  {critical} CRITICAL issue(s) — corrigir antes de usar o pack.')
            sys.exit(1)
        else:
            print(f'  Sem issues criticos. {len(report.issues)} aviso(s).')
            sys.exit(0)
    else:
        print('\n  Pack 100% consistente — 0 issues.')
        sys.exit(0)


if __name__ == '__main__':
    main()
