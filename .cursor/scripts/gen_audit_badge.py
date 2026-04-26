"""
update_audit_badge.py — actualiza o badge de consolidação no README.md raiz.

Roda validate_consolidated.py all e parseia o resultado:
- Se 0 FAIL → badge "19/19 PASS" verde.
- Se >0 FAIL → badge "X FAIL" vermelho.
- Indica também a contagem de WARN.

Uso:
    python .cursor/scripts/update_audit_badge.py
    python .cursor/scripts/update_audit_badge.py --strict
    python .cursor/scripts/update_audit_badge.py --report-path Documentation/Analise/audit_consolidado_atual.md

Política: .cursor/skills/project-consolidate-cursor_V1.1.0/SKILL.md
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path


WORKSPACE_ROOT = Path(__file__).resolve().parents[2]
README = WORKSPACE_ROOT / "README.md"
VALIDATOR = WORKSPACE_ROOT / ".cursor/scripts/validate_consolidated.py"

BADGE_PREFIX = "[![Consolidacao]"
BADGE_LINE_RE = re.compile(
    r"^\[!\[Consolidacao\]\([^)]+\)\]\([^)]+\)\s*$",
    re.MULTILINE,
)


def run_audit(strict: bool, report_path: str | None) -> tuple[int, int, str]:
    """Roda validador e devolve (fails, warns, report_path_used)."""
    if not VALIDATOR.is_file():
        print(f"erro: {VALIDATOR} não encontrado", file=sys.stderr)
        sys.exit(2)

    cmd = [sys.executable, str(VALIDATOR), "all"]
    if strict:
        cmd.append("--strict")
    if report_path:
        cmd.extend(["--output", report_path])

    proc = subprocess.run(cmd, capture_output=True, text=True, cwd=WORKSPACE_ROOT)
    out = proc.stdout + proc.stderr

    m = re.search(r"total_fails=(\d+)\s+total_warns=(\d+)", out)
    if not m:
        print("erro: não foi possível extrair contagens do output do validador", file=sys.stderr)
        print(out, file=sys.stderr)
        sys.exit(3)

    fails = int(m.group(1))
    warns = int(m.group(2))
    return fails, warns, report_path or ""


def render_badge(fails: int, warns: int, link_target: str) -> str:
    if fails == 0 and warns == 0:
        label = "19%2F19_PASS"
        color = "brightgreen"
    elif fails == 0:
        label = f"19%2F19_PASS_({warns}_WARN)"
        color = "yellow"
    else:
        label = f"{fails}_FAIL"
        color = "red"
    return (
        f"[![Consolidacao](https://img.shields.io/badge/consolidacao-{label}-{color}"
        f"?style=flat-square)]({link_target})"
    )


def update_readme(badge: str) -> bool:
    if not README.is_file():
        print(f"erro: {README} não encontrado", file=sys.stderr)
        return False
    text = README.read_text(encoding="utf-8")
    new_text, n = BADGE_LINE_RE.subn(badge, text, count=1)
    if n == 0:
        print("aviso: linha de badge não encontrada — README não foi modificado", file=sys.stderr)
        return False
    if new_text == text:
        print("badge já está actualizado — sem alterações.")
        return True
    README.write_text(new_text, encoding="utf-8")
    print(f"badge actualizado em {README}")
    return True


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Actualiza o badge de consolidação no README")
    p.add_argument("--strict", action="store_true", help="Promove WARN para FAIL")
    p.add_argument(
        "--report-path",
        default="Documentation/Analise/audit_consolidado_atual.md",
        help="Caminho do relatório de auditoria (também usado como link do badge)",
    )
    args = p.parse_args(argv)

    fails, warns, report = run_audit(args.strict, args.report_path)
    badge = render_badge(fails, warns, report)
    ok = update_readme(badge)

    print(f"resultado: {fails} FAIL, {warns} WARN")
    return 0 if ok and fails == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
