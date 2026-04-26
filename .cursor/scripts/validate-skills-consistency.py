#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
validate-skills-consistency.py — Lint de consistência do pack .cursor/

Regras:
  1. UTF-8 BOM em .md/.mdc (CRITICAL)
  2. Frontmatter YAML válido em skills/*/SKILL.md (CRITICAL)
  3. Match name <-> diretório sem sufixo _V* (CRITICAL)
  4. {$IFDEF FPC} / {$IFDEF MSWINDOWS} em blocos ```pascal (WARN)
  5. Refs quebradas: developer-delphi-orchestrator (sem master-), project-orchestrator, delphi-fpc-* (WARN)
  6. Acentos faltando em description (heurística) (WARN)

Uso:
    python validate-skills-consistency.py [--path .cursor] [--format text|json]

Exit code:
    0 — apenas WARN / OK
    1 — erros CRÍTICOS

# internal_file_version: 1.0.0
"""

from __future__ import annotations

import argparse
import io
import json
import os
import re
import sys
from pathlib import Path

# Force UTF-8 on stdout/stderr for Windows consoles
try:
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
except Exception:
    pass

BOM = b"\xef\xbb\xbf"

ACCENT_MAP = {
    "documentacao": "documentação",
    "excecoes": "exceções",
    "convencoes": "convenções",
    "publicacao": "publicação",
    "depuracao": "depuração",
    "expressoes": "expressões",
    "testes unitarios": "testes unitários",
    "integracao": "integração",
}

BROKEN_REF_PATTERNS = [
    (re.compile(r"\bdeveloper-delphi-orchestrator\b"), "developer-delphi-orchestrator (falta 'master-')"),
    (re.compile(r"(?<!master-)\bproject-orchestrator\b"), "project-orchestrator (falta 'master-')"),
    (re.compile(r"\bdelphi-fpc-[a-z-]+"), "ref legada delphi-fpc-*"),
]

IFDEF_PATTERN = re.compile(r"\{\$IFDEF\s+(FPC|MSWINDOWS|WINDOWS|LINUX|DARWIN|POSIX)\b", re.IGNORECASE)
ANTIPATTERN_MARKERS = ("anti-padrão", "antipadrão", "anti-pattern", "❌", "NÃO FAÇA", "evitar")

FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
NAME_RE = re.compile(r"^name:\s*(.+?)\s*$", re.MULTILINE)
DESC_RE = re.compile(r"^description:\s*(.+?)\s*$", re.MULTILINE)
MODEL_RE = re.compile(r"^model:\s*(.+?)\s*$", re.MULTILINE)


class Finding:
    __slots__ = ("severity", "path", "line", "rule", "message")

    def __init__(self, severity: str, path: str, line: int, rule: str, message: str):
        self.severity = severity
        self.path = path
        self.line = line
        self.rule = rule
        self.message = message

    def to_dict(self) -> dict:
        return {
            "severity": self.severity,
            "path": self.path,
            "line": self.line,
            "rule": self.rule,
            "message": self.message,
        }

    def format_text(self) -> str:
        return f"[{self.severity}] {self.path}:{self.line}:{self.rule} — {self.message}"


def strip_version_suffix(name: str) -> str:
    return re.sub(r"_V\d+\.\d+\.\d+$", "", name)


def check_bom(path: Path, findings: list[Finding]) -> bytes:
    try:
        data = path.read_bytes()
    except OSError as exc:
        findings.append(Finding("CRITICAL", str(path), 0, "R1", f"falha ao ler: {exc}"))
        return b""
    if data.startswith(BOM):
        findings.append(Finding("CRITICAL", str(path), 1, "R1-BOM", "ficheiro começa com UTF-8 BOM (quebra frontmatter YAML)"))
        data = data[len(BOM):]
    return data


def check_frontmatter_and_name(path: Path, text: str, findings: list[Finding]) -> None:
    # Só aplica a skills/*/SKILL.md
    parts = path.parts
    is_skill_md = (
        path.name == "SKILL.md"
        and "skills" in parts
    )
    if not is_skill_md:
        return

    if not text.startswith("---"):
        findings.append(Finding("CRITICAL", str(path), 1, "R2-frontmatter", "não inicia com '---' (frontmatter ausente)"))
        return

    m = FRONTMATTER_RE.match(text)
    if not m:
        findings.append(Finding("CRITICAL", str(path), 1, "R2-frontmatter", "frontmatter não fechado (ausente '---' final)"))
        return

    front = m.group(1)
    name_m = NAME_RE.search(front)
    desc_m = DESC_RE.search(front)
    model_m = MODEL_RE.search(front)

    if not name_m:
        findings.append(Finding("CRITICAL", str(path), 2, "R2-name", "campo 'name:' ausente no frontmatter"))
    if not desc_m:
        findings.append(Finding("CRITICAL", str(path), 2, "R2-desc", "campo 'description:' ausente no frontmatter"))
    else:
        desc_val = desc_m.group(1).strip()
        if not desc_val or desc_val == "---":
            findings.append(Finding("CRITICAL", str(path), 2, "R2-desc", "description vazia ou '---'"))
        else:
            # R6 — acentos
            lower = desc_val.lower()
            for bad, good in ACCENT_MAP.items():
                # match palavra (ou bigrama) isolada
                pattern = r"\b" + re.escape(bad) + r"\b"
                if re.search(pattern, lower):
                    findings.append(Finding(
                        "WARN", str(path), 2, "R6-acentos",
                        f"description usa '{bad}' (provavelmente falta acento: '{good}')"
                    ))
    if not model_m:
        findings.append(Finding("CRITICAL", str(path), 2, "R2-model", "campo 'model:' ausente no frontmatter"))

    # R3 — name ↔ diretório
    if name_m:
        name_val = name_m.group(1).strip()
        # diretório da skill: .../skills/<dir>/SKILL.md
        try:
            skills_idx = parts.index("skills")
            skill_dir = parts[skills_idx + 1]
        except (ValueError, IndexError):
            return
        expected = strip_version_suffix(skill_dir)
        if name_val != expected:
            findings.append(Finding(
                "CRITICAL", str(path), 2, "R3-name-match",
                f"name='{name_val}' não bate com diretório '{skill_dir}' (esperado '{expected}')"
            ))


def check_pascal_ifdef(path: Path, text: str, findings: list[Finding]) -> None:
    lines = text.splitlines()
    in_pascal = False
    fence_start_line = 0
    pascal_buf: list[tuple[int, str]] = []

    def flush_block(block: list[tuple[int, str]]) -> None:
        for i, (lineno, line) in enumerate(block):
            if IFDEF_PATTERN.search(line):
                # checar até 3 linhas acima por anti-padrão
                context_start = max(0, i - 3)
                context = "\n".join(l for _, l in block[context_start:i]).lower()
                if any(marker.lower() in context for marker in ANTIPATTERN_MARKERS):
                    continue
                findings.append(Finding(
                    "WARN", str(path), lineno, "R4-ifdef-pascal",
                    f"'{{$IFDEF ...}}' dentro de bloco pascal sem marcador de anti-padrão"
                ))

    for idx, line in enumerate(lines, start=1):
        stripped = line.strip().lower()
        if not in_pascal:
            if stripped.startswith("```pascal") or stripped.startswith("```delphi") or stripped.startswith("```object pascal"):
                in_pascal = True
                fence_start_line = idx
                pascal_buf = []
        else:
            if stripped.startswith("```"):
                flush_block(pascal_buf)
                in_pascal = False
                pascal_buf = []
            else:
                pascal_buf.append((idx, line))
    if in_pascal:
        # fence não fechado — ainda assim checa
        flush_block(pascal_buf)


def check_broken_refs(path: Path, text: str, findings: list[Finding]) -> None:
    # skip changelogs
    name_lower = path.name.lower()
    if "changelog" in name_lower:
        return
    for idx, line in enumerate(text.splitlines(), start=1):
        for pattern, desc in BROKEN_REF_PATTERNS:
            if pattern.search(line):
                findings.append(Finding(
                    "WARN", str(path), idx, "R5-ref-quebrada",
                    f"referência suspeita: {desc}"
                ))


def iter_target_files(root: Path):
    for dirpath, _dirnames, filenames in os.walk(root):
        for fn in filenames:
            if fn.lower().endswith((".md", ".mdc")):
                yield Path(dirpath) / fn


def main() -> int:
    ap = argparse.ArgumentParser(description="Lint de consistência do pack .cursor/")
    ap.add_argument("--path", default=".cursor", help="Raiz do pack (default: .cursor)")
    ap.add_argument("--format", choices=["text", "json"], default="text")
    args = ap.parse_args()

    root = Path(args.path).resolve()
    if not root.exists():
        print(f"[ERRO] path não existe: {root}", file=sys.stderr)
        return 2

    findings: list[Finding] = []
    files_scanned = 0
    for fpath in iter_target_files(root):
        files_scanned += 1
        raw = check_bom(fpath, findings)
        if not raw:
            continue
        try:
            text = raw.decode("utf-8")
        except UnicodeDecodeError as exc:
            findings.append(Finding("CRITICAL", str(fpath), 0, "R1-utf8", f"não é UTF-8 válido: {exc}"))
            continue
        check_frontmatter_and_name(fpath, text, findings)
        check_pascal_ifdef(fpath, text, findings)
        check_broken_refs(fpath, text, findings)

    crit = sum(1 for f in findings if f.severity == "CRITICAL")
    warn = sum(1 for f in findings if f.severity == "WARN")

    if args.format == "json":
        payload = {
            "files_scanned": files_scanned,
            "totals": {"critical": crit, "warn": warn},
            "findings": [f.to_dict() for f in findings],
        }
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        print(f"validate-skills-consistency — path: {root}")
        print(f"Ficheiros inspecionados: {files_scanned}")
        print(f"Totais: {crit} CRITICAL | {warn} WARN")
        print("-" * 72)
        if not findings:
            print("OK — nenhuma inconsistência detectada.")
        else:
            # agrupar por regra
            by_rule: dict[str, list[Finding]] = {}
            for f in findings:
                by_rule.setdefault(f.rule, []).append(f)
            for rule in sorted(by_rule):
                bucket = by_rule[rule]
                print(f"\n## {rule}  ({len(bucket)} ocorrência(s))")
                for f in bucket:
                    print(f.format_text())

    return 1 if crit > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
