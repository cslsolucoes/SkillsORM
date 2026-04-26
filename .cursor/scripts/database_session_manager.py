#!/usr/bin/env python3
"""
database_session_manager.py — Gerenciador de Sessão CLI de Bancos de Dados

Cobre 5 SGBDs: SQL Server, MySQL, SQLite, PostgreSQL, Firebird.
Fluxo: detecta cache existente → pergunta tipo de banco/credenciais →
varredura automática → loop interativo com renovação a cada 15 min +
política de retenção (7 dias) para caches antigos.

Localização canónica: .cursor/scripts/database_session_manager.py
Executar a partir da raiz do workspace:
    python .cursor/scripts/database_session_manager.py

Dependências: apenas biblioteca padrão (os, sys, glob, time, subprocess,
datetime, argparse, pathlib).
"""

import argparse
import glob
import os
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

# ── Encoding no terminal Windows ─────────────────────────────────────────────

if sys.stdout.encoding and sys.stdout.encoding.lower() not in ("utf-8", "utf8"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if sys.stderr.encoding and sys.stderr.encoding.lower() not in ("utf-8", "utf8"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

# ── Constantes ───────────────────────────────────────────────────────────────

SCRIPT_DIR     = Path(__file__).resolve().parent
WORKSPACE_ROOT = SCRIPT_DIR.parents[1]                  # .cursor/scripts → .cursor → raiz
CACHE_PREFIX   = "ss_"
CACHE_TTL      = 900                                    # 15 min em segundos
RETENTION_DAYS = 7                                      # caches mais velhos que 7 dias
RETENTION_SEC  = RETENTION_DAYS * 86400

SGBD_FOLDER = {
    "sqlserver":  "MSSqlcmd",
    "mysql":      "MySQL",
    "sqlite":     "SQLite",
    "postgresql": "PostgreSQL",
    "firebird":   "Firebird",
}

SGBD_LABEL = {
    "sqlserver":  "SQL Server",
    "mysql":      "MySQL",
    "sqlite":     "SQLite",
    "postgresql": "PostgreSQL",
    "firebird":   "Firebird",
}

SGBD_CLI = {
    "sqlserver":  WORKSPACE_ROOT / "MSSqlcmd" / "sqlcmd.exe",
    "mysql":      WORKSPACE_ROOT / "MySQL" / "bin" / "mysql.exe",
    "sqlite":     WORKSPACE_ROOT / "SQLite" / "sqlite3.exe",
    "postgresql": Path(r"C:\Program Files\PostgreSQL\18\bin\psql.exe"),
    "firebird":   Path(r"C:\Program Files\Firebird\Firebird_2_5\bin\isql.exe"),
}


def cache_dir(sgbd: str) -> Path:
    return WORKSPACE_ROOT / SGBD_FOLDER[sgbd]


def host_safe(host: str) -> str:
    return host.replace(".", "").replace(":", "").replace("/", "").replace("\\", "") or "local"


# ── Descoberta e retenção de caches ──────────────────────────────────────────

def find_all_caches() -> list[dict]:
    """Lista todos os caches ss_*.md em todas as pastas de SGBDs."""
    out = []
    now = int(time.time())
    for sgbd, folder in SGBD_FOLDER.items():
        pattern = str(WORKSPACE_ROOT / folder / f"{CACHE_PREFIX}*.md")
        for f in sorted(glob.glob(pattern), key=os.path.getmtime, reverse=True):
            base = Path(f).stem
            parts = base.split("_")
            if len(parts) < 3:
                continue
            try:
                ts = int(parts[-1])
            except ValueError:
                continue
            age = now - ts
            out.append({
                "sgbd":    sgbd,
                "file":    f,
                "ts":      ts,
                "age":     age,
                "expired": age > CACHE_TTL,
                "stale":   age > RETENTION_SEC,
            })
    return out


def parse_cache_meta(filepath: str) -> dict:
    meta = {"sgbd": "?", "host": "?", "port": "?", "user": "?", "database": "?"}
    try:
        with open(filepath, encoding="utf-8") as f:
            for line in f:
                if "**SGBD:**" in line:
                    for part in line.split("|"):
                        part = part.strip(" >\n")
                        for key, tag in (
                            ("sgbd",     "**SGBD:**"),
                            ("host",     "**Host:**"),
                            ("user",     "**Usuário:**"),
                            ("database", "**Database:**"),
                        ):
                            if tag in part:
                                meta[key] = part.split(tag, 1)[-1].strip()
                    break
    except Exception:
        pass
    return meta


def cleanup_stale_caches(caches: list[dict]) -> None:
    stale = [c for c in caches if c["stale"]]
    if not stale:
        return

    print(f"\nEncontrei {len(stale)} cache(s) com mais de {RETENTION_DAYS} dias (candidatos a limpeza):\n")
    for i, c in enumerate(stale, 1):
        meta = parse_cache_meta(c["file"])
        dias = c["age"] // 86400
        print(f"  [{i}] {Path(c['file']).name} — {dias} dias "
              f"({SGBD_LABEL[c['sgbd']]}, host={meta['host']})")
    print(f"\n  [a] Deletar TODOS (recomendado)")
    print(f"  [b] Manter todos")
    print(f"  [c] Escolher um a um")
    choice = input("\nEscolha: ").strip().lower()

    if choice == "a":
        for c in stale:
            try:
                os.remove(c["file"])
                print(f"  deletado: {Path(c['file']).name}")
            except OSError as e:
                print(f"  falha ao deletar {Path(c['file']).name}: {e}")
    elif choice == "c":
        for c in stale:
            ans = input(f"  Deletar {Path(c['file']).name}? [s/N] ").strip().lower()
            if ans == "s":
                try:
                    os.remove(c["file"])
                    print(f"    deletado")
                except OSError as e:
                    print(f"    falha: {e}")


# ── Execução CLI por SGBD ────────────────────────────────────────────────────

def run_sqlcmd(host, user, password, query, database=None, port=None) -> tuple[str, int]:
    exe = SGBD_CLI["sqlserver"]
    if not exe.exists():
        print(f"ERRO: sqlcmd não encontrado em {exe}")
        return "", 1
    target = f"{host},{port}" if port else host
    cmd = [str(exe), "-S", target, "-U", user, "-P", password, "-W"]
    if database:
        cmd += ["-d", database]
    cmd += ["-Q", query]
    r = subprocess.run(cmd, capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
    return r.stdout, r.returncode


def run_sqlite(dbfile, query) -> tuple[str, int]:
    exe = SGBD_CLI["sqlite"]
    if not exe.exists():
        print(f"ERRO: sqlite3 não encontrado em {exe}")
        return "", 1
    r = subprocess.run(
        [str(exe), "-header", "-separator", "|", dbfile, query],
        capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    return r.stdout, r.returncode


def run_psql(host, port, user, password, database, query) -> tuple[str, int]:
    exe = SGBD_CLI["postgresql"]
    if not exe.exists():
        print(f"ERRO: psql não encontrado em {exe}")
        return "", 1
    env = os.environ.copy()
    env["PGPASSWORD"] = password
    cmd = [str(exe), "-h", host, "-p", str(port or 5432), "-U", user,
           "-d", database, "-At", "-F", "|", "-c", query,
           "-v", "ON_ERROR_STOP=1"]
    r = subprocess.run(cmd, capture_output=True, text=True,
                       encoding="utf-8", errors="replace", env=env)
    return r.stdout, r.returncode


def run_mysql(host, port, user, password, database, query) -> tuple[str, int]:
    exe = SGBD_CLI["mysql"]
    if not exe.exists():
        print(f"ERRO: mysql não encontrado em {exe}")
        return "", 1
    cmd = [str(exe), "-h", host, "-P", str(port or 3306), "-u", user,
           f"-p{password}", "--batch", "-e", query]
    if database:
        cmd.append(database)
    r = subprocess.run(cmd, capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
    return r.stdout, r.returncode


def run_isql(host, port, user, password, fdb_path, query) -> tuple[str, int]:
    exe = SGBD_CLI["firebird"]
    if not exe.exists():
        print(f"ERRO: isql não encontrado em {exe}")
        return "", 1
    target = f"{host}/{port or 3050}:{fdb_path}" if host else fdb_path
    cmd = [str(exe), "-u", user, "-p", password, "-q", target]
    r = subprocess.run(cmd, input=query + "\nEXIT;\n", capture_output=True,
                       text=True, encoding="utf-8", errors="replace")
    return r.stdout, r.returncode


def clean_rows(output: str, skip=("TABLE_NAME", "name", "---", "(", "rows")) -> list[str]:
    return [
        line.strip() for line in output.splitlines()
        if line.strip() and not any(line.strip().startswith(s) for s in skip)
    ]


# ── Varredura por SGBD ───────────────────────────────────────────────────────

def scan_sqlserver(host, port, user, password) -> dict | None:
    q_dbs = ("SET NOCOUNT ON; SELECT name FROM sys.databases "
             "WHERE name NOT IN ('master','tempdb','model','msdb') ORDER BY name;")
    out, code = run_sqlcmd(host, user, password, q_dbs, port=port)
    if code != 0:
        print(f"Falha na varredura: {out}")
        return None
    dbs = clean_rows(out)
    if not dbs:
        print("Nenhum banco de aplicação encontrado.")
        return None

    tree = {}
    for db in dbs:
        print(f"  [{db}]...", end="\r", flush=True)
        q_tables = ("SET NOCOUNT ON; SELECT TABLE_SCHEMA + '.' + TABLE_NAME "
                    "FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' "
                    "ORDER BY TABLE_SCHEMA, TABLE_NAME;")
        out, _ = run_sqlcmd(host, user, password, q_tables, database=db, port=port)
        schemas = {}
        for line in clean_rows(out):
            if "." in line:
                schema, tbl = line.split(".", 1)
                schemas.setdefault(schema.strip(), []).append(tbl.strip())
        tree[db] = schemas
    print(" " * 50, end="\r")
    return tree


def scan_sqlite(dbfile) -> dict | None:
    q = ("SELECT name FROM sqlite_master WHERE type='table' "
         "AND name NOT LIKE 'sqlite_%' ORDER BY name;")
    out, code = run_sqlite(dbfile, q)
    if code != 0:
        print(f"Falha na varredura: {out}")
        return None
    tables = clean_rows(out, skip=("name",))
    db_name = Path(dbfile).stem
    return {db_name: {"main": tables}}


def scan_postgresql(host, port, user, password, database) -> dict | None:
    q_dbs = ("SELECT datname FROM pg_database "
             "WHERE datname NOT IN ('template0','template1','postgres') ORDER BY datname;")
    out, code = run_psql(host, port, user, password, database or "postgres", q_dbs)
    if code != 0:
        print(f"Falha: {out}")
        return None
    dbs = [d for d in clean_rows(out) if d]
    tree = {}
    for db in dbs:
        q_tables = ("SELECT table_schema || '|' || table_name "
                    "FROM information_schema.tables WHERE table_type='BASE TABLE' "
                    "AND table_schema NOT IN ('pg_catalog','information_schema') "
                    "ORDER BY table_schema, table_name;")
        out, _ = run_psql(host, port, user, password, db, q_tables)
        schemas = {}
        for line in clean_rows(out):
            if "|" in line:
                schema, tbl = line.split("|", 1)
                schemas.setdefault(schema.strip(), []).append(tbl.strip())
        tree[db] = schemas
    return tree


def scan_mysql(host, port, user, password) -> dict | None:
    q_dbs = ("SHOW DATABASES;")
    out, code = run_mysql(host, port, user, password, None, q_dbs)
    if code != 0:
        print(f"Falha: {out}")
        return None
    dbs = [d for d in clean_rows(out, skip=("Database",))
           if d not in ("mysql", "performance_schema", "information_schema", "sys")]
    tree = {}
    for db in dbs:
        out, _ = run_mysql(host, port, user, password, db,
                           "SHOW TABLES;")
        tables = clean_rows(out, skip=("Tables_in_",))
        tree[db] = {"default": tables}
    return tree


def scan_firebird(host, port, user, password, fdb_path) -> dict | None:
    q = ("SET LIST ON; SELECT RDB$RELATION_NAME FROM RDB$RELATIONS "
         "WHERE RDB$SYSTEM_FLAG = 0 AND RDB$RELATION_TYPE = 0 "
         "ORDER BY RDB$RELATION_NAME;")
    out, code = run_isql(host, port, user, password, fdb_path, q)
    if code != 0:
        print(f"Falha: {out}")
        return None
    tables = [ln.split("=", 1)[-1].strip() for ln in out.splitlines()
              if "RDB$RELATION_NAME" in ln]
    db_name = Path(fdb_path).stem
    return {db_name: {"default": tables}}


# ── Cache (leitura / escrita) ────────────────────────────────────────────────

def save_cache(sgbd, host, port, user, database, tree, preserve_columns="") -> tuple[str, int]:
    ts   = int(time.time())
    path = cache_dir(sgbd) / f"{CACHE_PREFIX}{sgbd}_{host_safe(host)}_{ts}.md"
    path.parent.mkdir(parents=True, exist_ok=True)
    now  = datetime.now().strftime("%Y-%m-%d %H:%M")

    lines = [
        f"# Cache {SGBD_LABEL[sgbd]} — {host}",
        "",
        f"> **Gerado em:** {now}",
        f"> **SGBD:** {SGBD_LABEL[sgbd]} | **Host:** {host}:{port or '-'} "
        f"| **Usuário:** {user} | **Database:** {database or '-'}",
        "",
        "## Mapa de bancos e tabelas",
        "",
    ]
    for db, schemas in tree.items():
        lines += [f"### Database: {db}", ""]
        for schema, tables in schemas.items():
            lines += [
                f"#### Schema: {schema}",
                "",
                f"Tabelas ({len(tables)}): {', '.join(tables)}",
                "",
            ]

    if preserve_columns:
        lines.append(preserve_columns)
    else:
        lines += [
            "## Colunas inspecionadas",
            "",
            "<!-- Preenchido automaticamente ao inspecionar colunas de tabelas específicas -->",
        ]

    path.write_text("\n".join(lines), encoding="utf-8")
    return str(path), ts


def load_cache_map(filepath: str) -> dict:
    tree = {}
    current_db = current_schema = None
    with open(filepath, encoding="utf-8") as f:
        for line in f:
            line = line.rstrip()
            if line.startswith("### Database:"):
                current_db = line.replace("### Database:", "").strip()
                tree[current_db] = {}
                current_schema = None
            elif line.startswith("#### Schema:") and current_db is not None:
                current_schema = line.replace("#### Schema:", "").strip()
                tree[current_db][current_schema] = []
            elif line.startswith("Tabelas") and current_db and current_schema:
                tables = line.split(":", 1)[-1].strip()
                tree[current_db][current_schema] = [
                    t.strip() for t in tables.split(",") if t.strip()
                ]
            elif line.startswith("## Colunas"):
                break
    return tree


def extract_columns_section(filepath: str) -> str:
    if not filepath or not os.path.exists(filepath):
        return ""
    content = Path(filepath).read_text(encoding="utf-8")
    idx = content.find("## Colunas inspecionadas")
    if idx == -1:
        return ""
    tail = content[idx:].strip()
    if tail.startswith("## Colunas inspecionadas") and "<!--" in tail.split("\n", 2)[2] if len(tail.split("\n")) > 2 else False:
        return ""
    return content[idx:]


# ── Loop interativo ──────────────────────────────────────────────────────────

def print_map(tree: dict, sgbd: str, cache_file: str | None) -> None:
    total = sum(len(tbls) for schemas in tree.values() for tbls in schemas.values())
    print(f"\n  {SGBD_LABEL[sgbd]} — {len(tree)} database(s), {total} tabela(s)")
    for db, schemas in tree.items():
        for schema, tables in schemas.items():
            print(f"    {db}.{schema:<15} {len(tables):>4} tabelas")
    if cache_file:
        print(f"\n  Cache: {Path(cache_file).name}")
        print(f"  Renovação automática: a cada {CACHE_TTL // 60} min")
        print(f"  Retenção: {RETENTION_DAYS} dias")


def print_help() -> None:
    print("""
  Comandos:
    bancos                   — lista databases
    tabelas <database>       — lista tabelas do database
    colunas <tabela>         — inspeciona colunas com PK
    limpar [--older-than N]  — remove caches > N dias (default: 7)
    mapa                     — mapa de sessão atual
    ajuda / ?                — este menu
    sair                     — encerra a sessão
""")


def handle_limpar(args: list[str]) -> None:
    days = RETENTION_DAYS
    if "--older-than" in args:
        try:
            days = int(args[args.index("--older-than") + 1])
        except (ValueError, IndexError):
            print("Uso: limpar [--older-than N]")
            return
    cutoff = int(time.time()) - days * 86400
    caches = find_all_caches()
    targets = [c for c in caches if c["ts"] < cutoff]
    if not targets:
        print(f"Nenhum cache com mais de {days} dias.")
        return
    print(f"\n{len(targets)} cache(s) com mais de {days} dias:")
    for c in targets:
        d = c["age"] // 86400
        print(f"  {Path(c['file']).name} — {d} dias ({SGBD_LABEL[c['sgbd']]})")
    if input("\nDeletar todos? [s/N] ").strip().lower() == "s":
        for c in targets:
            try:
                os.remove(c["file"])
            except OSError:
                pass
        print(f"  {len(targets)} arquivo(s) removido(s).")


def handle_command(raw: str, sgbd: str, conn: dict, tree: dict, cache_file: str) -> None:
    parts = raw.strip().split()
    low   = raw.lower().strip()

    if low in ("bancos", "\\l"):
        for db, schemas in tree.items():
            n = sum(len(t) for t in schemas.values())
            print(f"  {db:<25} {n:>4} tabelas")
        return

    if low.startswith(("tabelas", "\\dt")):
        for db in tree:
            if db.lower() in low:
                print(f"\n{db}:")
                for schema, tables in tree[db].items():
                    for t in tables:
                        print(f"  {schema}.{t}")
                return
        print("Informe o database. Ex: tabelas MeuBanco")
        print("Disponíveis:", ", ".join(tree.keys()))
        return

    if low.startswith("limpar"):
        handle_limpar(parts[1:])
        return

    if low in ("mapa", "status"):
        print_map(tree, sgbd, cache_file)
        return

    if low in ("ajuda", "help", "?"):
        print_help()
        return

    print(f"Comando não reconhecido: '{raw}'. Digite 'ajuda'.")


# ── Prompts de credenciais ───────────────────────────────────────────────────

def prompt_sgbd() -> str:
    print("\nTipo de banco:")
    options = list(SGBD_FOLDER.keys())
    for i, key in enumerate(options, 1):
        print(f"  [{i}] {SGBD_LABEL[key]}")
    choice = input("Escolha (1-5): ").strip()
    try:
        idx = int(choice) - 1
        return options[idx] if 0 <= idx < len(options) else options[0]
    except (ValueError, IndexError):
        return options[0]


def prompt_credentials(sgbd: str) -> dict:
    print(f"\nDados de conexão — {SGBD_LABEL[sgbd]}:\n")
    if sgbd == "sqlite":
        return {"dbfile": input("  Arquivo .db:  ").strip(),
                "host": "local", "port": 0, "user": "-", "password": "",
                "database": None}
    if sgbd == "firebird":
        return {"host":     input("  Host / IP:    ").strip(),
                "port":     input("  Porta (3050): ").strip() or "3050",
                "user":     input("  Usuário:      ").strip(),
                "password": input("  Senha:        ").strip(),
                "fdb_path": input("  Caminho .fdb: ").strip(),
                "database": None}
    return {"host":     input("  Host / IP:    ").strip(),
            "port":     input("  Porta:        ").strip(),
            "user":     input("  Usuário:      ").strip(),
            "password": input("  Senha:        ").strip(),
            "database": input("  Database:     ").strip() or None}


def run_scan(sgbd: str, conn: dict) -> dict | None:
    print("\nVarredura em andamento...")
    if sgbd == "sqlserver":
        return scan_sqlserver(conn["host"], conn["port"], conn["user"], conn["password"])
    if sgbd == "sqlite":
        return scan_sqlite(conn["dbfile"])
    if sgbd == "postgresql":
        return scan_postgresql(conn["host"], conn["port"], conn["user"],
                                conn["password"], conn["database"])
    if sgbd == "mysql":
        return scan_mysql(conn["host"], conn["port"], conn["user"], conn["password"])
    if sgbd == "firebird":
        return scan_firebird(conn["host"], conn["port"], conn["user"],
                              conn["password"], conn["fdb_path"])
    return None


# ── Main ─────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Gerenciador de sessão CLI para 5 SGBDs")
    parser.add_argument("--sgbd", choices=list(SGBD_FOLDER.keys()),
                        help="Tipo de banco (pula o prompt)")
    parser.add_argument("--workspace-root", type=Path,
                        help="Sobrescreve WORKSPACE_ROOT auto-detectado")
    parser.add_argument("--limpar", action="store_true",
                        help="Só limpa caches antigos e sai")
    parser.add_argument("--older-than", type=int, default=RETENTION_DAYS,
                        help=f"TTL em dias para --limpar (default {RETENTION_DAYS})")
    args = parser.parse_args()

    global WORKSPACE_ROOT
    if args.workspace_root:
        WORKSPACE_ROOT = args.workspace_root.resolve()

    print("=" * 60)
    print("  database_session_manager — 5 SGBDs")
    print(f"  Workspace: {WORKSPACE_ROOT}")
    print("=" * 60)

    if args.limpar:
        handle_limpar(["--older-than", str(args.older_than)])
        return

    # Limpeza automática proposta
    caches = find_all_caches()
    if any(c["stale"] for c in caches):
        cleanup_stale_caches(caches)
        caches = find_all_caches()

    sgbd = args.sgbd or prompt_sgbd()
    conn = prompt_credentials(sgbd)

    tree = run_scan(sgbd, conn)
    if not tree:
        print("Varredura falhou. Abortando.")
        sys.exit(1)

    cache_file, _ = save_cache(sgbd, conn.get("host", "local"),
                                conn.get("port"), conn.get("user"),
                                conn.get("database"), tree)

    print_map(tree, sgbd, cache_file)
    print("\nDigite 'ajuda' para ver os comandos disponíveis.")
    print("-" * 60)

    last_refresh = int(time.time())

    while True:
        try:
            raw = input("\n> ").strip()
        except (KeyboardInterrupt, EOFError):
            print("\nSessão encerrada.")
            break

        if not raw:
            continue
        if raw.lower() in ("sair", "exit", "quit"):
            print("Sessão encerrada.")
            break

        now = int(time.time())
        if now - last_refresh > CACHE_TTL:
            print("[Cache expirado — renovando mapa...]")
            cols = extract_columns_section(cache_file)
            new_tree = run_scan(sgbd, conn)
            if new_tree:
                tree = new_tree
                cache_file, _ = save_cache(sgbd, conn.get("host", "local"),
                                            conn.get("port"), conn.get("user"),
                                            conn.get("database"), tree, cols)
                last_refresh = now
                print(f"[Mapa atualizado — {datetime.now().strftime('%H:%M')}]")

        handle_command(raw, sgbd, conn, tree, cache_file)


if __name__ == "__main__":
    main()
