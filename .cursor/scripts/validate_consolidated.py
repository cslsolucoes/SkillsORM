#!/usr/bin/env python3
"""
validate_consolidated.py — Orquestrador de consolidação/auditoria do workspace.

Suporta 3 alvos:
  - cursor  : audita .cursor/ (versões, links, estrutura, nomenclatura, /init, autostart)
  - docs    : audita Documentation/ (versões, links, estrutura, nomenclatura, hub, GestorDoc)
  - source  : audita projects/ (cabeçalhos Pascal, uses, estrutura, nomenclatura, build, gitignore)
  - all     : executa os 3 em sequência e concatena relatórios

Uso:
    python .cursor/scripts/validate_consolidated.py <alvo> [--check <dim>] [--output <file>]
    python .cursor/scripts/validate_consolidated.py all

Read-only — nunca altera arquivos. Gera relatório Markdown.

# internal_file_version: 1.0.0
# Changelog:
# - 1.0.0 (16/04/2026): versão inicial — 3 alvos + 6-7 checks cada.
"""

import argparse
import glob
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

# ── Encoding no Windows ──────────────────────────────────────────────────────

if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf8"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# ── Constantes ───────────────────────────────────────────────────────────────

SCRIPT_DIR = Path(__file__).resolve().parent
WORKSPACE_ROOT = SCRIPT_DIR.parents[1]  # .cursor/scripts → .cursor → raiz

PACK_DIRS = ["skills", "rules", "agents", "commands", "Templates", "scripts", "plans"]
MANIFEST_DIRS = ["skills", "rules", "agents", "commands", "Templates", "scripts"]

DOC_DIRS = [
    "Analise", "Arquitetura", "BancoDados", "Estrutura", "Exports",
    "Mapeamento", "Planejamento", "RegrasNegocio", "Roteiro", "Versionamento",
]

PYTHON_PREFIXES = ("bootstrap_", "sync_", "validate_", "decompile_", "gen_", "database_")
POWERSHELL_PREFIXES = ("bootstrap-", "sync-", "decompile-", "database-", "scaffold-", "transform-")

MARKDOWN_LINK_RE = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")
VERSION_SUFFIX_RE = re.compile(r"_V(\d+\.\d+\.\d+)$")
FILEVERSION_RE = re.compile(r"\*\*FileVersion\*\*\s*\|\s*(\d+\.\d+\.\d+)")
PASCAL_HEADER_RE = re.compile(r"^\s*\{\s*=+", re.MULTILINE)

GESTORDOC_SECTIONS = [
    r"^#\s", r"^##\s+Metadados", r"^##\s+Descri", r"^##\s+Regras",
    r"^##\s+Condi", r"^##\s+Exce", r"^##\s+Depend", r"^##\s+Impacto",
    r"^##\s+Rastreabilidade", r"^##\s+Testes", r"^##\s+Hist", r"^##\s+Refer",
]


# ── Modelo de resultado ──────────────────────────────────────────────────────

class CheckResult:
    def __init__(self, name: str):
        self.name = name
        self.items_checked = 0
        self.failures: list[str] = []
        self.warnings: list[str] = []

    @property
    def status(self) -> str:
        if self.failures:
            return "FAIL"
        if self.warnings:
            return "WARNING"
        return "PASS"

    def add_fail(self, msg: str) -> None:
        self.failures.append(msg)

    def add_warn(self, msg: str) -> None:
        self.warnings.append(msg)


class Report:
    def __init__(self, target: str):
        self.target = target
        self.timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
        self.checks: list[CheckResult] = []

    def add(self, check: CheckResult) -> None:
        self.checks.append(check)

    def to_markdown(self) -> str:
        lines = [
            f"# Consolidação — {self.target} — {self.timestamp}",
            "",
            "## Resumo",
            "",
            "| Dimensão | Status | Itens | Falhas |",
            "|----------|:------:|------:|-------:|",
        ]
        total_pass = total_fail = total_warn = 0
        for c in self.checks:
            lines.append(f"| {c.name} | {c.status} | {c.items_checked} | {len(c.failures)} |")
            if c.status == "PASS": total_pass += 1
            elif c.status == "FAIL": total_fail += 1
            else: total_warn += 1
        lines += [
            "",
            f"**Total:** {total_pass} PASS, {total_fail} FAIL, {total_warn} WARNING.",
            "",
            "## Detalhes por dimensão",
            "",
        ]
        for c in self.checks:
            lines += [f"### {c.name} — {c.status}", ""]
            if c.failures:
                for f in c.failures[:50]:
                    lines.append(f"- [FAIL] {f}")
                if len(c.failures) > 50:
                    lines.append(f"- ... (+{len(c.failures) - 50} outros)")
            if c.warnings:
                for w in c.warnings[:20]:
                    lines.append(f"- [WARN] {w}")
            if not c.failures and not c.warnings:
                lines.append(f"- [PASS] {c.items_checked} itens verificados.")
            lines.append("")
        lines += [
            "## Recomendações acionáveis",
            "",
            "1. Corrigir falhas listadas por dimensão.",
            f"2. Re-executar `python .cursor/scripts/validate_consolidated.py {self.target}` para confirmar.",
            "",
        ]
        return "\n".join(lines)


# ── Helpers ──────────────────────────────────────────────────────────────────

def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return ""


def rel(path: Path) -> str:
    try:
        return str(path.relative_to(WORKSPACE_ROOT))
    except ValueError:
        return str(path)


def check_links_in_file(md_path: Path, repo_root: Path) -> list[str]:
    """Retorna lista de links quebrados em `md_path`."""
    broken = []
    content = read_text(md_path)
    for i, line in enumerate(content.splitlines(), 1):
        for m in MARKDOWN_LINK_RE.finditer(line):
            target = m.group(2).strip()
            if target.startswith(("http://", "https://", "#", "mailto:")):
                continue
            target_path = target.split("#")[0]
            if not target_path:
                continue
            resolved = (md_path.parent / target_path).resolve()
            if not resolved.exists():
                broken.append(f"{rel(md_path)}:{i} → `{target}`")
    return broken


# ── Checks: CURSOR ───────────────────────────────────────────────────────────

def check_cursor_version(report: Report) -> None:
    r = CheckResult("1. Versionamento")
    try:
        result = subprocess.run(
            [sys.executable, str(SCRIPT_DIR / "validate_pack.py")],
            capture_output=True, text=True, encoding="utf-8", errors="replace",
            cwd=str(WORKSPACE_ROOT), timeout=120,
        )
        r.items_checked = 1
        if result.returncode != 0:
            for line in (result.stdout + result.stderr).splitlines():
                if "CRITICAL" in line or "ERROR" in line:
                    r.add_fail(line.strip())
    except Exception as e:
        r.add_warn(f"validate_pack.py não pôde ser executado: {e}")
    report.add(r)


def check_cursor_links(report: Report) -> None:
    r = CheckResult("2. Links quebrados")
    for md in (WORKSPACE_ROOT / ".cursor").rglob("*.md"):
        r.items_checked += 1
        for broken in check_links_in_file(md, WORKSPACE_ROOT):
            r.add_fail(broken)
    report.add(r)


def check_cursor_structure(report: Report) -> None:
    r = CheckResult("3. Estruturação")
    cursor = WORKSPACE_ROOT / ".cursor"
    for d in PACK_DIRS:
        r.items_checked += 1
        if not (cursor / d).is_dir():
            r.add_fail(f"Pasta ausente: `.cursor/{d}/`")
    for d in MANIFEST_DIRS:
        manifest = list((cursor / d).glob(f"{d}-pack-manifest_V*.md")) if (cursor / d).is_dir() else []
        r.items_checked += 1
        if not manifest:
            r.add_fail(f"Manifesto ausente: `.cursor/{d}/{d}-pack-manifest_V*.md`")
    report.add(r)


def check_cursor_naming(report: Report) -> None:
    r = CheckResult("4. Nomenclatura")
    # Skills
    skills = WORKSPACE_ROOT / ".cursor" / "skills"
    if skills.is_dir():
        for d in skills.iterdir():
            if d.is_dir() and d.name != "plans":
                r.items_checked += 1
                if not VERSION_SUFFIX_RE.search(d.name):
                    if not d.name.endswith((".md",)) and "manifest" not in d.name:
                        r.add_fail(f"Skill sem sufixo _V{{X.Y.Z}}: `{rel(d)}`")
    # Rules
    rules = WORKSPACE_ROOT / ".cursor" / "rules"
    if rules.is_dir():
        for f in rules.glob("*.mdc"):
            r.items_checked += 1
            stem = f.stem
            if not VERSION_SUFFIX_RE.search(stem):
                r.add_fail(f"Rule sem sufixo _V{{X.Y.Z}}: `{rel(f)}`")
    # Scripts Python
    scripts_dir = WORKSPACE_ROOT / ".cursor" / "scripts"
    if scripts_dir.is_dir():
        for f in scripts_dir.glob("*.py"):
            r.items_checked += 1
            if not f.name.startswith(PYTHON_PREFIXES):
                r.add_fail(f"Script Python sem prefixo válido: `{rel(f)}`")
        for f in scripts_dir.glob("*.ps1"):
            r.items_checked += 1
            if not f.name.startswith(POWERSHELL_PREFIXES):
                r.add_fail(f"Script PowerShell sem prefixo válido: `{rel(f)}`")
    report.add(r)


def check_cursor_init(report: Report) -> None:
    r = CheckResult("5. /init executado")
    dpr = list(WORKSPACE_ROOT.glob("*.dpr")) + list((WORKSPACE_ROOT / "projects").glob("*.dpr"))
    lpr = list(WORKSPACE_ROOT.glob("*.lpr")) + list((WORKSPACE_ROOT / "projects").glob("*.lpr"))
    r.items_checked = 1
    if not dpr and not lpr:
        r.add_fail("Nenhum `.dpr` ou `.lpr` detectado na raiz ou em projects/. Executar /init.")
    report.add(r)


def check_cursor_autostart(report: Report) -> None:
    r = CheckResult("6. Autostart (espelhos)")
    try:
        result = subprocess.run(
            ["powershell", "-ExecutionPolicy", "Bypass",
             "-File", str(SCRIPT_DIR / "bootstrap-mirror-symlinks.ps1"),
             "-ValidateOnly"],
            capture_output=True, text=True, encoding="utf-8", errors="replace",
            cwd=str(WORKSPACE_ROOT), timeout=60,
        )
        r.items_checked = 1
        if result.returncode != 0:
            r.add_fail(f"bootstrap-mirror-symlinks retornou {result.returncode}")
    except FileNotFoundError:
        r.add_warn("PowerShell ou script bootstrap-mirror-symlinks.ps1 não encontrado.")
    except Exception as e:
        r.add_warn(f"Não foi possível executar: {e}")
    report.add(r)


def run_cursor(checks: list[str]) -> Report:
    report = Report("cursor")
    runners = {
        "version": check_cursor_version,
        "links": check_cursor_links,
        "structure": check_cursor_structure,
        "naming": check_cursor_naming,
        "init": check_cursor_init,
        "autostart": check_cursor_autostart,
    }
    for name in checks:
        if name in runners:
            runners[name](report)
    return report


# ── Checks: DOCS ─────────────────────────────────────────────────────────────

def check_docs_version(report: Report) -> None:
    r = CheckResult("1. Versionamento")
    docs = WORKSPACE_ROOT / "Documentation"
    if not docs.is_dir():
        report.add(r)
        return
    for md in docs.rglob("*.md"):
        r.items_checked += 1
        content = read_text(md)
        if "FileVersion" not in content and not VERSION_SUFFIX_RE.search(md.stem):
            r.add_fail(f"Sem FileVersion: `{rel(md)}`")
    report.add(r)


def check_docs_links(report: Report) -> None:
    r = CheckResult("2. Links quebrados")
    docs = WORKSPACE_ROOT / "Documentation"
    if not docs.is_dir():
        report.add(r)
        return
    for md in docs.rglob("*.md"):
        r.items_checked += 1
        for broken in check_links_in_file(md, WORKSPACE_ROOT):
            r.add_fail(broken)
    report.add(r)


def check_docs_structure(report: Report) -> None:
    r = CheckResult("3. Estruturação")
    docs = WORKSPACE_ROOT / "Documentation"
    if not docs.is_dir():
        r.add_fail("Pasta `Documentation/` ausente.")
        report.add(r)
        return
    for d in DOC_DIRS:
        r.items_checked += 1
        if not (docs / d).is_dir():
            r.add_fail(f"Subpasta obrigatória ausente: `Documentation/{d}/`")
    report.add(r)


def check_docs_naming(report: Report) -> None:
    r = CheckResult("4. Nomenclatura")
    docs = WORKSPACE_ROOT / "Documentation"
    if not docs.is_dir():
        report.add(r)
        return
    # Analise/
    for md in (docs / "Analise").rglob("*.md") if (docs / "Analise").is_dir() else []:
        r.items_checked += 1
        if md.stem.startswith(("T", "I")) and len(md.stem) > 1 and md.stem[1].isupper():
            r.add_fail(f"Prefixo T/I em Analise/: `{rel(md)}` → renomear sem prefixo")
    # RegrasNegocio/
    rn_re = re.compile(r"^RN-M\d{2}-\d{3}$")
    for md in (docs / "RegrasNegocio").rglob("*.md") if (docs / "RegrasNegocio").is_dir() else []:
        r.items_checked += 1
        if not rn_re.match(md.stem):
            r.add_fail(f"RN fora do padrão RN-MXX-NNN: `{rel(md)}`")
    report.add(r)


def check_docs_hub(report: Report) -> None:
    r = CheckResult("5. Hub e Changelog")
    docs = WORKSPACE_ROOT / "Documentation"
    r.items_checked = 2
    readmes = list(docs.glob("README*.md")) if docs.is_dir() else []
    if not readmes:
        r.add_fail("Hub ausente: `Documentation/README.md` ou `README_Vx.y.md`.")
    changelog = docs / "Versionamento" / "CHANGELOG.md"
    if not changelog.exists():
        r.add_fail(f"Changelog ausente: `{rel(changelog)}`")
    report.add(r)


def check_docs_html(report: Report) -> None:
    r = CheckResult("6. Portal HTML")
    docs = WORKSPACE_ROOT / "Documentation"
    r.items_checked = 2
    if docs.is_dir():
        if not (docs / "html" / "index.html").exists():
            r.add_warn("`Documentation/html/index.html` ausente (opcional).")
        if not (docs / "html" / "docs-data.js").exists():
            r.add_warn("`Documentation/html/docs-data.js` ausente (opcional).")
    report.add(r)


def check_docs_gestordoc(report: Report) -> None:
    r = CheckResult("7. Formato GestorDoc")
    rn_dir = WORKSPACE_ROOT / "Documentation" / "RegrasNegocio"
    if not rn_dir.is_dir():
        report.add(r)
        return
    patterns = [re.compile(p, re.MULTILINE) for p in GESTORDOC_SECTIONS]
    for md in rn_dir.rglob("*.md"):
        r.items_checked += 1
        content = read_text(md)
        missing = [f"seção {i+1}" for i, p in enumerate(patterns) if not p.search(content)]
        if missing:
            r.add_fail(f"`{rel(md)}` — faltam: {', '.join(missing)}")
    report.add(r)


def run_docs(checks: list[str]) -> Report:
    report = Report("documentação")
    runners = {
        "version": check_docs_version,
        "links": check_docs_links,
        "structure": check_docs_structure,
        "naming": check_docs_naming,
        "hub": check_docs_hub,
        "html": check_docs_html,
        "gestordoc": check_docs_gestordoc,
    }
    for name in checks:
        if name in runners:
            runners[name](report)
    return report


# ── Checks: SOURCE ───────────────────────────────────────────────────────────

def check_source_headers(report: Report) -> None:
    r = CheckResult("1. Cabeçalhos Pascal")
    proj = WORKSPACE_ROOT / "projects"
    if not proj.is_dir():
        report.add(r)
        return
    for ext in ("*.pas", "*.dpr", "*.lpr"):
        for src in proj.rglob(ext):
            # Ignorar pacotes de terceiros e binários
            if "package" in src.parts or "Compiled" in src.parts:
                continue
            r.items_checked += 1
            content = read_text(src)[:500]
            if not PASCAL_HEADER_RE.search(content):
                r.add_warn(f"Sem header padrão: `{rel(src)}`")
    report.add(r)


def check_source_uses(report: Report) -> None:
    r = CheckResult("2. Uses quebrados (heurístico)")
    r.items_checked = 1
    r.add_warn("Check heurístico — validar compilação real via `dcc32`/`fpc` para precisão.")
    report.add(r)


def check_source_structure(report: Report) -> None:
    r = CheckResult("3. Estruturação MXX")
    backend = WORKSPACE_ROOT / "projects" / "backend"
    if not backend.is_dir():
        r.items_checked = 1
        r.add_warn("`projects/backend/` ainda não existe.")
        report.add(r)
        return
    for mdir in backend.iterdir():
        if not mdir.is_dir() or not mdir.name.startswith("M"):
            continue
        r.items_checked += 1
        for sub in ("Core", "Commons", "Modulos"):
            if not (mdir / sub).is_dir():
                r.add_fail(f"`{rel(mdir)}` — subpasta ausente: `{sub}/`")
    report.add(r)


def check_source_naming(report: Report) -> None:
    r = CheckResult("4. Nomenclatura Pascal")
    backend = WORKSPACE_ROOT / "projects" / "backend"
    if not backend.is_dir():
        report.add(r)
        return
    for pas in backend.rglob("*.pas"):
        r.items_checked += 1
        if "Commons" in pas.parts and not pas.stem.startswith("Commons."):
            r.add_fail(f"Arquivo em Commons/ sem prefixo `Commons.`: `{rel(pas)}`")
    report.add(r)


def check_source_build(report: Report) -> None:
    r = CheckResult("5. Build CLI (configs presentes)")
    proj = WORKSPACE_ROOT / "projects"
    dprs = list(proj.glob("*.dpr"))
    lprs = list(proj.glob("*.lpr"))
    r.items_checked = len(dprs) + len(lprs)
    if dprs and not (proj / "dcc32.cfg").exists():
        r.add_fail("`.dpr` presente mas `projects/dcc32.cfg` ausente.")
    if lprs and not (proj / "fpc32.opts").exists():
        r.add_fail("`.lpr` presente mas `projects/fpc32.opts` ausente.")
    report.add(r)


def check_source_ignore(report: Report) -> None:
    r = CheckResult("6. Binários em .gitignore")
    gi = WORKSPACE_ROOT / ".gitignore"
    r.items_checked = 1
    if not gi.exists():
        r.add_fail("`.gitignore` ausente na raiz.")
        report.add(r)
        return
    content = read_text(gi)
    required = ["Compiled/", "*.exe", "*.dcu", "*.identcache"]
    for pat in required:
        if pat not in content:
            r.add_fail(f"Padrão ausente em `.gitignore`: `{pat}`")
    report.add(r)


def run_source(checks: list[str]) -> Report:
    report = Report("código fonte")
    runners = {
        "headers": check_source_headers,
        "uses": check_source_uses,
        "structure": check_source_structure,
        "naming": check_source_naming,
        "build": check_source_build,
        "ignore": check_source_ignore,
    }
    for name in checks:
        if name in runners:
            runners[name](report)
    return report


# ── CLI ──────────────────────────────────────────────────────────────────────

DEFAULT_CHECKS = {
    "cursor": ["version", "links", "structure", "naming", "init", "autostart"],
    "docs":   ["version", "links", "structure", "naming", "hub", "html", "gestordoc"],
    "source": ["headers", "uses", "structure", "naming", "build", "ignore"],
}


def main() -> None:
    parser = argparse.ArgumentParser(description="Orquestrador de consolidação do workspace")
    parser.add_argument("target", choices=["cursor", "docs", "source", "all"],
                        help="Alvo da auditoria")
    parser.add_argument("--check", default="all",
                        help="Dimensão específica (ou 'all'). Depende do alvo.")
    parser.add_argument("--output", type=Path,
                        help="Arquivo de saída (Markdown). Default: stdout.")
    args = parser.parse_args()

    targets = ["cursor", "docs", "source"] if args.target == "all" else [args.target]
    reports: list[Report] = []

    for t in targets:
        checks = DEFAULT_CHECKS[t] if args.check == "all" else [args.check]
        if t == "cursor":
            reports.append(run_cursor(checks))
        elif t == "docs":
            reports.append(run_docs(checks))
        elif t == "source":
            reports.append(run_source(checks))

    output = "\n\n---\n\n".join(r.to_markdown() for r in reports)

    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(output, encoding="utf-8")
        print(f"Relatório gravado em: {args.output}")
    else:
        print(output)

    exit_code = 1 if any(c.failures for r in reports for c in r.checks) else 0
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
