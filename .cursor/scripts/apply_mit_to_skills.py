from __future__ import annotations

import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]


LEGAL_BLOCK = [
    "license: MIT",
    'copyright: "Copyright (c) 2026 CSL Tech Solutions"',
    'company: "CSL Tech Solutions"',
    'author: "Claiton de Souza Linhares"',
]


def _split_frontmatter(text: str) -> tuple[str | None, str, str]:
    """
    Returns: (frontmatter_block_without_fences | None, body, newline)
    newline is either '\n' or '\r\n' based on input.
    """
    newline = "\r\n" if "\r\n" in text else "\n"
    if not text.startswith("---" + newline):
        return None, text, newline

    end = text.find(newline + "---" + newline)
    if end == -1:
        # malformed; treat as no frontmatter
        return None, text, newline

    fm = text[len("---" + newline) : end]
    body = text[end + len(newline + "---" + newline) :]
    return fm, body, newline


def _ensure_legal_in_frontmatter(fm: str, newline: str) -> tuple[str, bool]:
    """
    Ensures LEGAL_BLOCK keys exist with correct values.
    Injects missing keys and updates known keys when value differs.
    Returns (new_fm, changed).
    """
    changed = False
    fm_lines = fm.splitlines()

    desired_by_key: dict[str, str] = {}
    for line in LEGAL_BLOCK:
        key, value = line.split(":", 1)
        desired_by_key[key.strip()] = value.lstrip()

    # index existing keys
    key_to_idx: dict[str, int] = {}
    for idx, raw in enumerate(fm_lines):
        if ":" not in raw:
            continue
        k = raw.split(":", 1)[0].strip()
        if k:
            key_to_idx[k] = idx

    # update existing values or append missing keys
    for key, desired_value in desired_by_key.items():
        if key in key_to_idx:
            idx = key_to_idx[key]
            current_value = fm_lines[idx].split(":", 1)[1].lstrip()
            if current_value != desired_value:
                fm_lines[idx] = f"{key}: {desired_value}"
                changed = True
        else:
            fm_lines.append(f"{key}: {desired_value}")
            changed = True

    return newline.join(fm_lines), changed


def apply_to_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    fm, body, newline = _split_frontmatter(original)

    if fm is None:
        # Create minimal frontmatter with legal block and keep whole content as body.
        new_fm = newline.join(LEGAL_BLOCK)
        new_text = "---" + newline + new_fm + newline + "---" + newline + original.lstrip("\ufeff")
        if new_text != original:
            path.write_text(new_text, encoding="utf-8", newline=newline)
            return True
        return False

    new_fm, changed = _ensure_legal_in_frontmatter(fm, newline)
    if not changed:
        return False

    new_text = "---" + newline + new_fm + newline + "---" + newline + body
    path.write_text(new_text, encoding="utf-8", newline=newline)
    return True


def main() -> int:
    targets = [
        REPO_ROOT / ".cursor" / "skills",
        REPO_ROOT / ".workspace" / "skills",
    ]

    changed = 0
    scanned = 0
    for base in targets:
        if not base.exists():
            continue
        for skill_file in base.glob("**/SKILL.md"):
            scanned += 1
            if apply_to_file(skill_file):
                changed += 1

    print(f"[mit] scanned={scanned} changed={changed}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

