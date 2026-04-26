"""
bulk-add-fileversion.py — Adiciona bloco "Versão interna" ao fim de ficheiros .md
em Documentation/ que não tenham FileVersion nem sufixo _V<x.y.z> no nome.

Não toca em ficheiros já versionados (FileVersion no corpo OU sufixo _V<x.y.z>
no nome) nem em ficheiros dentro de Documentation/Backup/.

Uso:
    python bulk-add-fileversion.py            # dry-run (default)
    python bulk-add-fileversion.py --apply    # aplica alterações
    python bulk-add-fileversion.py --apply --root <path>
"""
from __future__ import annotations

import argparse
import re
import sys
from datetime import date
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
DOCS_DIR = WORKSPACE_ROOT / "Documentation"
VERSION_SUFFIX_RE = re.compile(r"_V\d+[\._]\d+(?:[\._]\d+)?$")
FILEVERSION_RE = re.compile(r"FileVersion", re.IGNORECASE)
TODAY = date.today().isoformat()

BLOCK_TEMPLATE = """

---

## Versão interna

| Campo           | Valor      |
| --------------- | ---------- |
| **FileVersion** | 1.0.0      |
| **Data**        | {today}    |
| **Bootstrap**   | bulk-add-fileversion (auditoria consolidada {today}) |
"""


def needs_block(md: Path) -> bool:
    if "Backup" in md.parts:
        return False
    if VERSION_SUFFIX_RE.search(md.stem):
        return False
    try:
        text = md.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return False
    if FILEVERSION_RE.search(text):
        return False
    return True


def add_block(md: Path, dry: bool) -> None:
    text = md.read_text(encoding="utf-8", errors="ignore")
    if not text.endswith("\n"):
        text += "\n"
    block = BLOCK_TEMPLATE.format(today=TODAY)
    if not dry:
        md.write_text(text + block, encoding="utf-8")


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--apply", action="store_true", help="Aplica (default: dry-run)")
    p.add_argument("--root", default=str(DOCS_DIR), help="Pasta raiz a varrer")
    args = p.parse_args()

    root = Path(args.root)
    if not root.is_dir():
        print(f"[erro] Pasta não existe: {root}", file=sys.stderr)
        return 2

    targets: list[Path] = []
    for md in root.rglob("*.md"):
        if needs_block(md):
            targets.append(md)

    mode = "APLICAR" if args.apply else "DRY-RUN"
    print(f"[{mode}] {len(targets)} ficheiros precisam de bloco FileVersion.\n")

    by_area: dict[str, int] = {}
    for md in targets:
        try:
            rel = md.relative_to(WORKSPACE_ROOT)
        except ValueError:
            rel = md
        area = rel.parts[1] if len(rel.parts) > 2 else "(raiz)"
        by_area[area] = by_area.get(area, 0) + 1

    print("Distribuição por área:")
    for a, n in sorted(by_area.items(), key=lambda x: -x[1]):
        print(f"  {n:5d}  Documentation/{a}/")

    if args.apply:
        print("\n[aplicando…]")
        for md in targets:
            add_block(md, dry=False)
        print(f"[OK] {len(targets)} ficheiros actualizados.")
    else:
        print("\nAmostra (primeiros 10):")
        for md in targets[:10]:
            print(f"  + {md.relative_to(WORKSPACE_ROOT)}")
        if len(targets) > 10:
            print(f"  … (+{len(targets)-10} outros)")
        print("\nRe-correr com --apply para escrever.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
