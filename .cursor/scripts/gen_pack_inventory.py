#!/usr/bin/env python3
"""
Gera pack-inventory.json escaneando .cursor/ e extraindo metadados.
Uso: python3 gen_pack_inventory.py [--incremental]
Saída: .cursor/pack-inventory.json

internal_file_version: 1.2.1
Changelog:
    - 1.2.1 (12/04/2026): _generated usa date.today().isoformat() em vez de string hardcoded '2026-04-09'.
    - 1.2.0 (11/04/2026): Renomeado de _gen_inventory.py — convenção gen_* para geradores.
    - 1.1.0 (09/04/2026): Modo --incremental com _file_mtimes — reprocessa
      apenas arquivos com mtime alterado; build completo salva mtimes.
    - 1.0.0 (09/04/2026): Geração inicial — 197 entradas com name, path,
      version, description, changelog.
"""
import re
import json
import sys
import argparse
from datetime import date
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

CURSOR_DIR = Path(__file__).resolve().parent.parent

# ---------------------------------------------------------------------------
# Extração de metadados
# ---------------------------------------------------------------------------

VER_PATTERNS = [
    re.compile(r'internal_file_version:\s*([0-9]+\.[0-9]+\.[0-9]+)'),
    re.compile(r'internal_template_version:\s*([0-9]+\.[0-9]+\.[0-9]+)'),
    # Formato tabela Markdown: | **FileVersion** | 1.1.0 |
    re.compile(r'\*\*FileVersion\*\*\s*\|\s*([0-9]+\.[0-9]+\.[0-9]+)'),
    re.compile(r'\*\*FolderVersion\*\*[:\s]+([0-9]+\.[0-9]+\.[0-9]+)'),
    re.compile(r'\*\*FileVersion\*\*[:\s]+([0-9]+\.[0-9]+\.[0-9]+)'),
    re.compile(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)', re.MULTILINE),
    re.compile(r'"_version":\s*"([^"]+)"'),
    re.compile(r'"_template_version":\s*"([^"]+)"'),
    re.compile(r'\.internal_version\s*=\s*["\']([^"\']+)["\']'),
]

CHANGELOG_RE = re.compile(
    r'[-*]\s*([0-9]+\.[0-9]+\.[0-9x]+\s*\([^)]+\)[^:\n]*:[^\n]+)', re.MULTILINE
)

def extract_version_from_name(name: str) -> str | None:
    m = re.search(r'_V([0-9]+\.[0-9]+(?:\.[0-9]+)?)', name)
    return m.group(1) if m else None

def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding='utf-8', errors='replace')
    except Exception:
        return ''

def extract_meta(path: Path, rel: str, text: str) -> dict:
    # Versão
    version = None
    for pat in VER_PATTERNS:
        m = pat.search(text)
        if m:
            version = m.group(1).strip()
            break
    if not version:
        version = extract_version_from_name(path.stem)

    # Descrição — frontmatter YAML
    desc = None
    fm_match = re.search(r'^---\s*\n(.*?)\n---', text, re.DOTALL)
    if fm_match:
        fm = fm_match.group(1)
        dm = re.search(r'^description:\s*(.+)', fm, re.MULTILINE)
        if dm:
            desc = dm.group(1).strip().strip('"\'')
    if not desc:
        # Docstring Python (primeira linha não-vazia)
        ds = re.search(r'^\s*"""(.*?)"""', text, re.DOTALL)
        if ds:
            first_line = ds.group(1).strip().split('\n')[0].strip()
            if first_line:
                desc = first_line
    if not desc:
        # PowerShell .SYNOPSIS
        sy = re.search(r'\.SYNOPSIS\s*\n\s*(.+)', text)
        if sy:
            desc = sy.group(1).strip()
    if not desc:
        # JSON _description
        jd = re.search(r'"_description"\s*:\s*"([^"]+)"', text)
        if jd:
            desc = jd.group(1).strip()
    if not desc:
        # Primeira linha de parágrafo (não título, não tabela, não código)
        in_frontmatter = False
        for line in text.split('\n'):
            s = line.strip()
            if s == '---':
                in_frontmatter = not in_frontmatter
                continue
            if in_frontmatter:
                continue
            if s and not s.startswith('#') and not s.startswith('|') \
               and not s.startswith('```') and not s.startswith('    ') \
               and not s.startswith('>') and len(s) > 15:
                desc = s[:200]
                break

    # Changelog — últimas 3
    changelog = []
    for m in CHANGELOG_RE.finditer(text):
        entry = m.group(1).strip()
        if entry not in changelog:
            changelog.append(entry)
    changelog = changelog[-3:] if changelog else None

    # path = somente o diretório (sem o nome do arquivo)
    rel_path = rel.replace('\\', '/')
    folder = '/'.join(rel_path.split('/')[:-1])  # remove o último segmento (filename)

    return {
        'name': path.name,
        'path': folder,          # apenas o diretório
        'version': version,
        'description': desc,
        'changelog': changelog,
    }

# ---------------------------------------------------------------------------
# Suporte incremental
# ---------------------------------------------------------------------------

def maybe_extract(path: Path, rel: str, incremental: bool,
                  existing_entries: dict, existing_mtimes: dict) -> dict:
    """
    Retorna entry cacheada se mtime não mudou (modo incremental),
    senão reextrai metadados e marca _mtime para persistência.
    """
    rel_key = rel.replace('\\', '/')
    try:
        current_mtime = path.stat().st_mtime
    except OSError:
        current_mtime = 0.0

    if incremental and rel_key in existing_mtimes:
        if abs(existing_mtimes[rel_key] - current_mtime) < 1.0:
            cached = existing_entries.get(rel_key)
            if cached:
                result = dict(cached)
                result['_mtime'] = current_mtime
                return result

    text = read_text(path)
    entry = extract_meta(path, rel, text)
    entry['_mtime'] = current_mtime
    return entry

# ---------------------------------------------------------------------------
# Contadores por área
# ---------------------------------------------------------------------------

def area_version(pattern: str) -> tuple[str | None, str | None]:
    """Retorna (manifest_filename, version) para um padrão glob.
    Prioridade: sufixo _Vx.y.z no nome do arquivo."""
    candidates = sorted(CURSOR_DIR.glob(pattern))
    if not candidates:
        return None, None
    f = candidates[-1]
    ver = extract_version_from_name(f.stem)
    if not ver:
        text = read_text(f)
        for pat in VER_PATTERNS:
            m = pat.search(text)
            if m:
                ver = m.group(1).strip()
                break
    return f.name, ver

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description='Gera pack-inventory.json escaneando .cursor/ e extraindo metadados.'
    )
    parser.add_argument('--incremental', action='store_true',
                        help='Reprocessa apenas arquivos com mtime alterado (mais rápido).')
    args = parser.parse_args()

    out_path = CURSOR_DIR / 'pack-inventory.json'

    # Valores padrão
    existing_version = '1.1.0'
    existing_changelog = [
        '1.1.0 (09/04/2026): Campo `path` alterado para conter apenas o diretório (sem nome do arquivo); '
        'regex de extração corrigido para formato de tabela `| **FileVersion** |`; '
        'versão adicionada a todos os 197 arquivos; adicionados manifestos de `commands/` e `scripts/`.',
        '1.0.0 (09/04/2026): Geração inicial — 196 entradas com name, path, version, description, changelog.',
    ]

    # Carregar inventário existente para preservar _version/_changelog e cache de mtimes
    existing_entries: dict = {}   # {rel_path: entry_dict}
    existing_mtimes:  dict = {}   # {rel_path: mtime_float}

    if out_path.exists():
        try:
            prev = json.loads(out_path.read_text(encoding='utf-8'))
            existing_version   = prev.get('_version',   existing_version)
            existing_changelog = prev.get('_changelog', existing_changelog)
            existing_mtimes    = prev.get('_file_mtimes', {})
            for entry in prev.get('files', []):
                key = (entry['path'] + '/' + entry['name']).lstrip('/')
                existing_entries[key] = entry
        except Exception:
            pass

    incremental = args.incremental

    files = []

    # ---- Raiz .cursor/ ----
    for name in ['README.md', 'VERSION.md', 'config.json']:
        p = CURSOR_DIR / name
        if p.exists():
            files.append(maybe_extract(p, name, incremental, existing_entries, existing_mtimes))

    # ---- scripts/ ----
    scripts_dir = CURSOR_DIR / 'scripts'
    for p in sorted(scripts_dir.iterdir()):
        if p.suffix in ('.py', '.ps1') and p.name != 'gen_pack_inventory.py':
            files.append(maybe_extract(p, f'scripts/{p.name}', incremental, existing_entries, existing_mtimes))

    # ---- rules/ ----
    rules_dir = CURSOR_DIR / 'rules'
    rules_count = 0
    for p in sorted(rules_dir.rglob('*')):
        if p.suffix in ('.mdc', '.md') and p.is_file():
            rel = p.relative_to(CURSOR_DIR)
            files.append(maybe_extract(p, str(rel), incremental, existing_entries, existing_mtimes))
            rules_count += 1

    # ---- commands/ ----
    commands_dir = CURSOR_DIR / 'commands'
    commands_count = 0
    for p in sorted(commands_dir.rglob('*.md')):
        if p.is_file():
            rel = p.relative_to(CURSOR_DIR)
            files.append(maybe_extract(p, str(rel), incremental, existing_entries, existing_mtimes))
            commands_count += 1

    # ---- agents/ ----
    agents_dir = CURSOR_DIR / 'agents'
    agents_count = 0
    for p in sorted(agents_dir.glob('*.md')):
        if p.is_file():
            files.append(maybe_extract(p, f'agents/{p.name}', incremental, existing_entries, existing_mtimes))
            agents_count += 1

    # ---- skills/ — só SKILL.md de cada subpasta ----
    skills_dir = CURSOR_DIR / 'skills'
    skills_count = 0
    for skill_dir in sorted(skills_dir.iterdir()):
        if skill_dir.is_dir():
            skill_md = skill_dir / 'SKILL.md'
            if skill_md.exists():
                ver = extract_version_from_name(skill_dir.name)
                entry = maybe_extract(skill_md, f'skills/{skill_dir.name}/SKILL.md',
                                      incremental, existing_entries, existing_mtimes)
                if ver:
                    entry['version'] = ver
                entry['name'] = skill_dir.name  # nome da skill (pasta)
                files.append(entry)
                skills_count += 1

    # Manifesto skills
    for p in sorted((skills_dir).glob('skills-pack-manifest_*.md')):
        files.append(maybe_extract(p, f'skills/{p.name}', incremental, existing_entries, existing_mtimes))

    # ---- Templates/ — raiz + mirror-config ----
    templates_dir = CURSOR_DIR / 'Templates'
    tpl_count = 0
    for p in sorted(templates_dir.glob('*')):
        if p.is_file() and p.suffix in ('.md', '.json', '.mdc'):
            files.append(maybe_extract(p, f'Templates/{p.name}', incremental, existing_entries, existing_mtimes))
            tpl_count += 1
    mirror_cfg_dir = templates_dir / 'mirror-config'
    if mirror_cfg_dir.is_dir():
        for p in sorted(mirror_cfg_dir.glob('*')):
            if p.is_file():
                files.append(maybe_extract(p, f'Templates/mirror-config/{p.name}',
                                           incremental, existing_entries, existing_mtimes))
                tpl_count += 1

    # ---- Áreas summary ----
    sm_skills,   sv_skills   = area_version('skills/skills-pack-manifest_*.md')
    sm_agents,   sv_agents   = area_version('agents/agents-pack-manifest_*.md')
    sm_rules,    sv_rules    = area_version('rules/rules-pack-manifest_*.md')
    sm_tpls,     sv_tpls     = area_version('Templates/templates-pack-manifest_*.md')
    sm_commands, sv_commands = area_version('commands/commands-pack-manifest_*.md')
    sm_scripts,  sv_scripts  = area_version('scripts/scripts-pack-manifest_*.md')

    scripts_count  = sum(1 for f in files if f['path'] == 'scripts')
    commands_count = sum(1 for f in files if f['path'] == 'commands')

    areas = {
        'skills':    {'manifest': sm_skills,    'version': sv_skills,    'count': skills_count},
        'agents':    {'manifest': sm_agents,    'version': sv_agents,    'count': agents_count},
        'rules':     {'manifest': sm_rules,     'version': sv_rules,     'count': rules_count},
        'templates': {'manifest': sm_tpls,      'version': sv_tpls,      'count': tpl_count},
        'commands':  {'manifest': sm_commands,  'version': sv_commands,  'count': commands_count},
        'scripts':   {'manifest': sm_scripts,   'version': sv_scripts,   'count': scripts_count},
    }

    # ---- Construir _file_mtimes e limpar campo interno _mtime dos entries ----
    file_mtimes: dict = {}
    for f in files:
        key = (f['path'] + '/' + f['name']).lstrip('/')
        if '_mtime' in f:
            file_mtimes[key] = f.pop('_mtime')

    # Preservar mtimes de entries que não foram varridas nesta execução
    # (ex: novos arquivos adicionados ao existente sem --incremental total)
    for key, mtime in existing_mtimes.items():
        if key not in file_mtimes:
            file_mtimes[key] = mtime

    inventory = {
        '_version':     existing_version,
        '_description': 'Inventário automático do pack .cursor/ — gerado por scripts/gen_pack_inventory.py',
        '_changelog':   existing_changelog,
        '_generated':   date.today().isoformat(),
        '_total_files': len(files),
        '_file_mtimes': file_mtimes,
        'areas': areas,
        'files': files,
    }

    out_path.write_text(json.dumps(inventory, ensure_ascii=False, indent=2), encoding='utf-8')
    mode_label = ' (incremental)' if incremental else ''
    print(f'[OK] {out_path}  ({len(files)} entradas){mode_label}')

if __name__ == '__main__':
    main()
