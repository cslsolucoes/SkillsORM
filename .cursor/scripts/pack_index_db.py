"""
pack_index_db.py — Gestor do índice SQLite (FTS5) do pack .cursor/ e .workspace/.

PROPÓSITO
---------
Mantém bases SQLite com FTS5 contendo metadados de todas as skills, agents,
rules e docs do workspace. Serve de índice rápido e offline, reduzindo tokens
e acelerando descoberta pela IA.

TRÊS BASES
----------
- .cursor/index.db    (pack: skills + agents + rules, propagado via sync)
- .workspace/index.db (workspace: prefixo <projectId>-* artefactos, não propagado)
- .docs/index.db      (project: docs técnicos locais — opcional, skip se ausente)

USO
---
    python .cursor/scripts/pack_index_db.py --init
    python .cursor/scripts/pack_index_db.py --scan cursor
    python .cursor/scripts/pack_index_db.py --scan workspace
    python .cursor/scripts/pack_index_db.py --scan project
    python .cursor/scripts/pack_index_db.py --scan all
    python .cursor/scripts/pack_index_db.py --query "parameters INI cascade"
    python .cursor/scripts/pack_index_db.py --query "logger" --type skill
    python .cursor/scripts/pack_index_db.py --query "<keyword>" --scope workspace
    python .cursor/scripts/pack_index_db.py --stats
    python .cursor/scripts/pack_index_db.py --full

FLAGS
-----
    --init                 Cria o schema se não existir (sem scan).
    --scan {cursor|workspace|project|all}
                           Varre pasta(s) e faz upsert incremental por hash.
                           scope 'project' é silenciosamente saltado se E:\\.docs\\ ausente.
    --full                 Drop + recreate (ignora cache; após mudança de schema).
    --query <keywords>     FTS5 query; devolve top-10 entries ordenadas por rank.
    --type {skill|agent|rule|doc}
                           Filtra query por tipo.
    --scope {cursor|workspace|project|all}
                           Filtra query por scope (default: all).
    --stats                Mostra contadores por tipo/categoria/scope.
    --dry-run              Não escreve; mostra o que faria.

ENTRADA
-------
- .cursor/skills/**/*.md
- .cursor/agents/**/*.md
- .cursor/rules/**/*.mdc
- .workspace/**/*.md|.mdc
- E:\\.docs\\**\\*.md            (scope project — opcional)

SAÍDA
-----
- .cursor/index.db
- .workspace/index.db
- E:\\.docs\\index.db           (apenas se E:\\.docs\\ existir)

DEPENDÊNCIAS
------------
Python stdlib apenas: sqlite3, pathlib, hashlib, json, re, argparse.
Zero dependência externa — o Python 3.8+ bundle inclui SQLite 3.24+ com FTS5.

AUTOR
-----
Gerado na Onda 1 do refactor (17/04/2026).
Plano canónico: D:/Users/claiton.linhares/.claude/plans/...glimmering-sunrise.md.

CHANGELOG
---------
1.1.0 (2026-04-18) — scope novo 'project' para docs técnicos locais (base própria
                      E:\\.docs\\index.db; skip silencioso se pasta ausente).
1.0.0 (2026-04-17) — versão inicial: schema base, scan incremental,
                      FTS5 query, stats.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sqlite3
import sys
from datetime import datetime, timezone
from pathlib import Path

# --------------------------------------------------------------------------- #
# Constantes

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
CURSOR_DIR = WORKSPACE_ROOT / ".cursor"
WORKSPACE_DIR = WORKSPACE_ROOT / ".workspace"
DOCS_DIR = Path(r"E:\.docs")

DB_CURSOR = CURSOR_DIR / "index.db"
DB_WORKSPACE = WORKSPACE_DIR / "index.db"
DB_PROJECT = DOCS_DIR / "index.db"

SCHEMA_VERSION = "1.0.0"

# Mapeamento: pasta dentro do scope -> type + glob pattern
SCOPE_MAP: dict[str, dict] = {
    "cursor": {
        "sources": [
            ("skill", "skills/**/SKILL.md"),  # Windows case-insensitive: apanha skill.md também
            ("agent", "agents/*.md"),
            ("rule", "rules/*.mdc"),
        ],
        "root": CURSOR_DIR,
        "db": DB_CURSOR,
    },
    "workspace": {
        "sources": [
            ("skill", "skills/**/SKILL.md"),
            ("agent", "agents/*.md"),
            ("rule", "rules/*.mdc"),
            ("doc", "Docs/**/*.md"),
        ],
        "root": WORKSPACE_DIR,
        "db": DB_WORKSPACE,
    },
    "project": {
        # Docs técnicos locais fora do repo (E:\.docs\ — Assembly/, Delphi/**).
        # Se a pasta não existir, _iter_files retorna silenciosamente (skip).
        "sources": [
            ("doc", "**/*.md"),
        ],
        "root": DOCS_DIR,
        "db": DB_PROJECT,
    },
}

# Scopes iterados por "all" (project só é incluído se E:\.docs\ existir)
ALL_SCOPES_BASE = ["cursor", "workspace"]


def _all_scopes() -> list[str]:
    """Devolve a lista de scopes para --scan all / --full / stats."""
    scopes = list(ALL_SCOPES_BASE)
    if DOCS_DIR.exists():
        scopes.append("project")
    return scopes

SCHEMA_SQL = """
CREATE TABLE IF NOT EXISTS artefacts (
  id            INTEGER PRIMARY KEY,
  type          TEXT NOT NULL,
  scope         TEXT NOT NULL,
  name          TEXT,
  path          TEXT NOT NULL UNIQUE,
  version       TEXT,
  description   TEXT,
  category      TEXT,
  model         TEXT,
  thinking      TEXT,
  keywords      TEXT,
  frontmatter   TEXT,
  content_hash  TEXT NOT NULL,
  modified_at   TEXT NOT NULL,
  indexed_at    TEXT NOT NULL
);

CREATE VIRTUAL TABLE IF NOT EXISTS artefacts_fts USING fts5(
  name, description, keywords, frontmatter,
  content='artefacts', content_rowid='id'
);

CREATE INDEX IF NOT EXISTS idx_type     ON artefacts(type);
CREATE INDEX IF NOT EXISTS idx_category ON artefacts(category);
CREATE INDEX IF NOT EXISTS idx_scope    ON artefacts(scope);
CREATE INDEX IF NOT EXISTS idx_model    ON artefacts(model);

CREATE TRIGGER IF NOT EXISTS artefacts_ai AFTER INSERT ON artefacts BEGIN
  INSERT INTO artefacts_fts(rowid, name, description, keywords, frontmatter)
  VALUES (new.id, new.name, new.description, new.keywords, new.frontmatter);
END;

CREATE TRIGGER IF NOT EXISTS artefacts_ad AFTER DELETE ON artefacts BEGIN
  INSERT INTO artefacts_fts(artefacts_fts, rowid, name, description, keywords, frontmatter)
  VALUES ('delete', old.id, old.name, old.description, old.keywords, old.frontmatter);
END;

CREATE TRIGGER IF NOT EXISTS artefacts_au AFTER UPDATE ON artefacts BEGIN
  INSERT INTO artefacts_fts(artefacts_fts, rowid, name, description, keywords, frontmatter)
  VALUES ('delete', old.id, old.name, old.description, old.keywords, old.frontmatter);
  INSERT INTO artefacts_fts(rowid, name, description, keywords, frontmatter)
  VALUES (new.id, new.name, new.description, new.keywords, new.frontmatter);
END;

CREATE TABLE IF NOT EXISTS meta (
  key    TEXT PRIMARY KEY,
  value  TEXT NOT NULL
);
"""

# --------------------------------------------------------------------------- #
# Utilitários

def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def _sha256(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
YAML_KV_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_-]*)\s*:\s*(.*?)\s*$")


def _parse_frontmatter(text: str) -> dict:
    """Parser YAML minimalista — chaves escalares e listas inline `[a, b]`."""
    match = FRONTMATTER_RE.match(text)
    if not match:
        return {}
    result: dict = {}
    current_key: str | None = None
    for raw_line in match.group(1).splitlines():
        if raw_line.startswith(("#", "---")) or not raw_line.strip():
            continue
        kv = YAML_KV_RE.match(raw_line)
        if kv:
            key = kv.group(1).strip()
            value = kv.group(2).strip()
            if value.startswith("[") and value.endswith("]"):
                items = [
                    s.strip().strip('"').strip("'")
                    for s in value[1:-1].split(",")
                    if s.strip()
                ]
                result[key] = items
            elif value in ("", ">", "|", ">-", "|-"):
                result[key] = ""
                current_key = key
            else:
                result[key] = value.strip('"').strip("'")
                current_key = None
        elif raw_line.startswith((" ", "\t")) and current_key is not None:
            stripped = raw_line.strip()
            if result.get(current_key):
                result[current_key] += " " + stripped
            else:
                result[current_key] = stripped
    return result


def _connect(db_path: Path) -> sqlite3.Connection:
    db_path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    conn.executescript(SCHEMA_SQL)
    conn.execute(
        "INSERT OR REPLACE INTO meta(key, value) VALUES (?, ?)",
        ("schema_version", SCHEMA_VERSION),
    )
    conn.commit()
    return conn


# --------------------------------------------------------------------------- #
# Operações

def init_db(scope: str) -> None:
    """Cria schema da(s) DB(s)."""
    scopes = _all_scopes() if scope == "all" else [scope]
    for s in scopes:
        cfg = SCOPE_MAP[s]
        if s == "project" and not DOCS_DIR.exists():
            print(r"[skip] E:\.docs\ ausente — scope 'project' ignorado")
            continue
        # Para 'project' precisamos garantir que a pasta-mãe da DB existe
        cfg["db"].parent.mkdir(parents=True, exist_ok=True)
        conn = _connect(cfg["db"])
        conn.close()
        print(f"[init] schema ok -> {cfg['db']}")


def drop_db(scope: str) -> None:
    """Apaga DB(s) — usado por --full."""
    scopes = _all_scopes() if scope == "all" else [scope]
    for s in scopes:
        cfg = SCOPE_MAP[s]
        if cfg["db"].exists():
            cfg["db"].unlink()
            print(f"[drop] apagada -> {cfg['db']}")


def _iter_files(scope_cfg: dict):
    root: Path = scope_cfg["root"]
    if not root.exists():
        return
    for artefact_type, pattern in scope_cfg["sources"]:
        for path in root.glob(pattern):
            if not path.is_file():
                continue
            # Ignorar manifestos e READMEs
            if path.name.startswith(("skills-pack-manifest", "agents-pack-manifest",
                                      "rules-pack-manifest", "templates-pack-manifest",
                                      "commands-pack-manifest", "scripts-pack-manifest",
                                      "rename-map", "docs-pack-manifest")):
                continue
            yield artefact_type, path


def scan_db(scope: str, *, dry_run: bool = False) -> dict:
    """Varre filesystem e faz upsert incremental. Devolve stats acumulados."""
    scopes = _all_scopes() if scope == "all" else [scope]
    grand_total = {"added": 0, "modified": 0, "deleted": 0, "unchanged": 0}

    for s in scopes:
        cfg = SCOPE_MAP[s]
        if s == "project" and not DOCS_DIR.exists():
            print(r"[skip] E:\.docs\ ausente — scope 'project' ignorado")
            continue
        # Garantir pasta-mãe da DB (crítico para scope 'project' em E:\.docs\)
        cfg["db"].parent.mkdir(parents=True, exist_ok=True)
        conn = _connect(cfg["db"])
        # Contadores por scope (reset a cada iteração)
        totals = {"added": 0, "modified": 0, "deleted": 0, "unchanged": 0}

        # Estado actual na DB
        existing: dict[str, str] = {
            row["path"]: row["content_hash"]
            for row in conn.execute("SELECT path, content_hash FROM artefacts")
        }
        seen: set[str] = set()

        for artefact_type, path in _iter_files(cfg):
            try:
                content = path.read_text(encoding="utf-8", errors="ignore")
            except Exception as exc:
                print(f"[warn] falha a ler {path}: {exc}", file=sys.stderr)
                continue

            if s == "project":
                rel = path.resolve().as_posix()
            else:
                rel = path.relative_to(WORKSPACE_ROOT).as_posix()
            seen.add(rel)
            content_hash = _sha256(content)

            if existing.get(rel) == content_hash:
                totals["unchanged"] += 1
                continue

            fm = _parse_frontmatter(content)
            name = fm.get("name") or path.stem
            kw = fm.get("keywords", "")
            if isinstance(kw, list):
                kw_str = ", ".join(kw)
            else:
                kw_str = str(kw)

            row = {
                "type": artefact_type,
                "scope": s,
                "name": name,
                "path": rel,
                "version": fm.get("version", ""),
                "description": fm.get("description", ""),
                "category": fm.get("category", ""),
                "model": fm.get("model", ""),
                "thinking": fm.get("thinking", ""),
                "keywords": kw_str,
                "frontmatter": json.dumps(fm, ensure_ascii=False),
                "content_hash": content_hash,
                "modified_at": datetime.fromtimestamp(
                    path.stat().st_mtime, tz=timezone.utc
                ).isoformat(timespec="seconds"),
                "indexed_at": _now_iso(),
            }

            if dry_run:
                continue

            if rel in existing:
                conn.execute(
                    """UPDATE artefacts SET
                       type=:type, scope=:scope, name=:name, version=:version,
                       description=:description, category=:category, model=:model,
                       thinking=:thinking, keywords=:keywords, frontmatter=:frontmatter,
                       content_hash=:content_hash, modified_at=:modified_at,
                       indexed_at=:indexed_at
                       WHERE path=:path""",
                    row,
                )
                totals["modified"] += 1
            else:
                conn.execute(
                    """INSERT INTO artefacts
                       (type, scope, name, path, version, description, category,
                        model, thinking, keywords, frontmatter, content_hash,
                        modified_at, indexed_at)
                       VALUES (:type, :scope, :name, :path, :version, :description,
                               :category, :model, :thinking, :keywords, :frontmatter,
                               :content_hash, :modified_at, :indexed_at)""",
                    row,
                )
                totals["added"] += 1

        # Deletar removidos
        to_delete = set(existing) - seen
        for rel in to_delete:
            if not dry_run:
                conn.execute("DELETE FROM artefacts WHERE path = ?", (rel,))
            totals["deleted"] += 1

        if not dry_run:
            conn.commit()
        conn.close()
        print(f"[scan {s}] db={cfg['db'].name} "
              f"+{totals['added']} ~{totals['modified']} -{totals['deleted']} "
              f"={totals['unchanged']}")
        for k, v in totals.items():
            grand_total[k] += v
    return grand_total


def query_db(keywords: str, *, type_filter: str | None = None,
             scope_filter: str = "all", limit: int = 10) -> list[dict]:
    """FTS5 query sobre artefacts. Devolve lista ordenada por rank."""
    scopes = _all_scopes() if scope_filter == "all" else [scope_filter]
    rows: list[dict] = []

    for s in scopes:
        cfg = SCOPE_MAP[s]
        if not cfg["db"].exists():
            continue
        conn = _connect(cfg["db"])
        query_sql = """
            SELECT a.*, bm25(artefacts_fts) AS rank
            FROM artefacts_fts
            JOIN artefacts a ON a.id = artefacts_fts.rowid
            WHERE artefacts_fts MATCH ?
        """
        params: list = [keywords]
        if type_filter:
            query_sql += " AND a.type = ?"
            params.append(type_filter)
        query_sql += " ORDER BY rank LIMIT ?"
        params.append(limit)

        try:
            for row in conn.execute(query_sql, params):
                rows.append(dict(row))
        except sqlite3.OperationalError as exc:
            print(f"[warn] FTS query falhou em {s}: {exc}", file=sys.stderr)
        conn.close()

    rows.sort(key=lambda r: r.get("rank", 0.0))
    return rows[:limit]


def stats_db() -> dict:
    """Contadores por type/category/scope para ambas DBs."""
    report = {}
    for s in _all_scopes():
        cfg = SCOPE_MAP[s]
        if not cfg["db"].exists():
            report[s] = {"error": "DB ainda não criada"}
            continue
        conn = _connect(cfg["db"])
        total = conn.execute("SELECT COUNT(*) FROM artefacts").fetchone()[0]
        by_type = dict(conn.execute(
            "SELECT type, COUNT(*) FROM artefacts GROUP BY type").fetchall())
        by_category = dict(conn.execute(
            "SELECT category, COUNT(*) FROM artefacts "
            "WHERE category != '' GROUP BY category").fetchall())
        report[s] = {
            "total": total,
            "by_type": by_type,
            "by_category": by_category,
            "db_path": str(cfg["db"]),
        }
        conn.close()
    return report


# --------------------------------------------------------------------------- #
# CLI

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Gestor do índice SQLite do pack .cursor/ + .workspace/"
    )
    parser.add_argument("--init", action="store_true",
                        help="Criar schema sem scan")
    parser.add_argument("--scan", choices=["cursor", "workspace", "project", "all"],
                        help=r"Varrer pasta e upsert incremental (project skip se E:\.docs\ ausente)")
    parser.add_argument("--full", action="store_true",
                        help="Drop + recreate (após mudança de schema)")
    parser.add_argument("--query", metavar="KEYWORDS",
                        help="FTS5 query; top-10 por rank")
    parser.add_argument("--type", dest="type_filter",
                        choices=["skill", "agent", "rule", "doc"],
                        help="Filtrar query por tipo")
    parser.add_argument("--scope", dest="scope_filter",
                        choices=["cursor", "workspace", "project", "all"],
                        default="all",
                        help="Filtrar query por scope (default: all)")
    parser.add_argument("--stats", action="store_true",
                        help="Mostrar contadores por tipo/category/scope")
    parser.add_argument("--dry-run", action="store_true",
                        help="Não escreve; mostra o que faria")

    args = parser.parse_args()

    # --full implica drop + scan
    if args.full:
        target = args.scan or "all"
        drop_db(target)
        init_db(target)
        scan_db(target, dry_run=args.dry_run)
        return 0

    if args.init:
        init_db(args.scan or "all")
        return 0

    if args.scan:
        scan_db(args.scan, dry_run=args.dry_run)
        return 0

    if args.query:
        results = query_db(
            args.query,
            type_filter=args.type_filter,
            scope_filter=args.scope_filter,
        )
        if not results:
            print("[query] sem resultados")
            return 0
        for r in results:
            desc = (r.get("description") or "").replace("\n", " ")[:80]
            print(f"[{r['type']:6s}] [{r['scope']:9s}] {r['name']} -- {desc}")
            print(f"         {r['path']}  (rank={r.get('rank', 0):.2f})")
        print(f"\nTotal: {len(results)} resultados")
        return 0

    if args.stats:
        report = stats_db()
        for scope, data in report.items():
            print(f"\n=== {scope} ===")
            if "error" in data:
                print(f"  {data['error']}")
                continue
            print(f"  total:       {data['total']}")
            print(f"  db:          {data['db_path']}")
            print(f"  by_type:     {data['by_type']}")
            if data.get("by_category"):
                print(f"  by_category: {data['by_category']}")
        return 0

    parser.print_help()
    return 1


if __name__ == "__main__":
    sys.exit(main())
