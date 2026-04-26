"""
gen_project_index.py — Inventário SQLite de todos os ficheiros do projecto

  ProjectVersion: 1.0.7
  FileVersion:    1.0.0
  Author:         Claiton de Souza Linhares
  Date:           22/04/2026

  Gera/actualiza project.index.db na raiz do projecto, indexando todos os
  ficheiros respeitando as regras do .gitignore existente.

  Uso:
    python .cursor/scripts/gen_project_index.py            # scan incremental
    python .cursor/scripts/gen_project_index.py --full     # drop + recreate
    python .cursor/scripts/gen_project_index.py --stats    # contadores por extensão
    python .cursor/scripts/gen_project_index.py --dry-run  # lista sem escrever

  Schema:
    files  — path, extension, size_bytes, sha256, modified_at, indexed_at
    meta   — key/value (root, indexed_at, total_files, gitignore_patterns)

  Changelog (file):
  - 1.0.0 (22/04/2026): Versão inicial — inventário com respeito ao .gitignore.
"""

import sys
import os
import sqlite3
import hashlib
import fnmatch
import datetime
import argparse

# ---------------------------------------------------------------------------
# Configuração
# ---------------------------------------------------------------------------

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, '..', '..'))
DB_PATH = os.path.join(PROJECT_ROOT, 'project.index.db')
GITIGNORE_PATH = os.path.join(PROJECT_ROOT, '.gitignore')

# Exclusões fixas independentes do .gitignore
ALWAYS_EXCLUDE_DIRS = {'.git', '__pycache__', 'Compiled'}
ALWAYS_EXCLUDE_FILES = {'project.index.db'}

# ---------------------------------------------------------------------------
# Parser de .gitignore minimalista (sem dependências externas)
# ---------------------------------------------------------------------------

def load_gitignore_patterns(gitignore_path):
    """Lê .gitignore e devolve (dir_patterns, file_patterns)."""
    dir_patterns = []
    file_patterns = []

    if not os.path.isfile(gitignore_path):
        return dir_patterns, file_patterns

    with open(gitignore_path, encoding='utf-8', errors='replace') as f:
        for raw in f:
            line = raw.strip()
            if not line or line.startswith('#'):
                continue
            # Padrão de directório: termina em '/'
            if line.endswith('/'):
                dir_patterns.append(line.rstrip('/'))
            else:
                file_patterns.append(line)

    return dir_patterns, file_patterns


def is_excluded_dir(dirname, dir_patterns):
    """Verdadeiro se o nome do directório corresponde a algum padrão."""
    if dirname in ALWAYS_EXCLUDE_DIRS:
        return True
    for pat in dir_patterns:
        if fnmatch.fnmatch(dirname, pat):
            return True
    return False


def is_excluded_file(filename, rel_path, file_patterns):
    """Verdadeiro se o ficheiro corresponde a algum padrão de exclusão."""
    if filename in ALWAYS_EXCLUDE_FILES:
        return True
    for pat in file_patterns:
        # Testar pelo nome simples e pelo caminho relativo
        if fnmatch.fnmatch(filename, pat):
            return True
        if fnmatch.fnmatch(rel_path.replace('\\', '/'), pat):
            return True
    return False

# ---------------------------------------------------------------------------
# Hashing
# ---------------------------------------------------------------------------

def sha256_file(path):
    h = hashlib.sha256()
    try:
        with open(path, 'rb') as f:
            for chunk in iter(lambda: f.read(65536), b''):
                h.update(chunk)
        return h.hexdigest()
    except OSError:
        return ''

# ---------------------------------------------------------------------------
# Varredura de ficheiros
# ---------------------------------------------------------------------------

def scan_files(root, dir_patterns, file_patterns):
    """Gera (rel_path, abs_path) para todos os ficheiros não excluídos."""
    for dirpath, dirnames, filenames in os.walk(root):
        # Filtrar directórios in-place (modifica a lista para os.walk não descer)
        dirnames[:] = [
            d for d in sorted(dirnames)
            if not is_excluded_dir(d, dir_patterns)
        ]

        rel_dir = os.path.relpath(dirpath, root)

        for fname in sorted(filenames):
            if rel_dir == '.':
                rel_path = fname
            else:
                rel_path = os.path.join(rel_dir, fname)

            rel_path_fwd = rel_path.replace('\\', '/')

            if is_excluded_file(fname, rel_path_fwd, file_patterns):
                continue

            yield rel_path_fwd, os.path.join(dirpath, fname)

# ---------------------------------------------------------------------------
# Base de dados
# ---------------------------------------------------------------------------

DDL = """
CREATE TABLE IF NOT EXISTS files (
    id          INTEGER PRIMARY KEY,
    path        TEXT    NOT NULL UNIQUE,
    extension   TEXT    NOT NULL,
    size_bytes  INTEGER NOT NULL,
    sha256      TEXT    NOT NULL,
    modified_at TEXT    NOT NULL,
    indexed_at  TEXT    NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_ext      ON files(extension);
CREATE INDEX IF NOT EXISTS idx_modified ON files(modified_at);

CREATE TABLE IF NOT EXISTS meta (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
"""


def open_db(db_path, full_reset=False):
    conn = sqlite3.connect(db_path)
    conn.execute('PRAGMA journal_mode=WAL')
    if full_reset:
        conn.execute('DROP TABLE IF EXISTS files')
        conn.execute('DROP TABLE IF EXISTS meta')
        conn.execute('DROP INDEX IF EXISTS idx_ext')
        conn.execute('DROP INDEX IF EXISTS idx_modified')
    conn.executescript(DDL)
    conn.commit()
    return conn


def upsert_file(conn, rel_path, abs_path, now_iso):
    stat = os.stat(abs_path)
    size = stat.st_size
    mtime = datetime.datetime.utcfromtimestamp(stat.st_mtime).strftime('%Y-%m-%dT%H:%M:%SZ')
    ext = os.path.splitext(rel_path)[1].lower() or '(none)'

    # Incremental: pular se tamanho e mtime não mudaram
    row = conn.execute(
        'SELECT size_bytes, modified_at FROM files WHERE path = ?', (rel_path,)
    ).fetchone()
    if row and row[0] == size and row[1] == mtime:
        return False  # sem alteração

    digest = sha256_file(abs_path)
    conn.execute(
        '''INSERT INTO files (path, extension, size_bytes, sha256, modified_at, indexed_at)
           VALUES (?, ?, ?, ?, ?, ?)
           ON CONFLICT(path) DO UPDATE SET
               extension  = excluded.extension,
               size_bytes = excluded.size_bytes,
               sha256     = excluded.sha256,
               modified_at= excluded.modified_at,
               indexed_at = excluded.indexed_at''',
        (rel_path, ext, size, digest, mtime, now_iso)
    )
    return True  # inserido ou actualizado


def remove_stale(conn, seen_paths):
    """Remove do índice ficheiros que já não existem no disco."""
    existing = {row[0] for row in conn.execute('SELECT path FROM files')}
    stale = existing - seen_paths
    for p in stale:
        conn.execute('DELETE FROM files WHERE path = ?', (p,))
    return len(stale)


def update_meta(conn, root, now_iso, total, patterns_count):
    pairs = [
        ('root', root.replace('\\', '/')),
        ('indexed_at', now_iso),
        ('total_files', str(total)),
        ('gitignore_patterns', str(patterns_count)),
    ]
    for key, val in pairs:
        conn.execute(
            'INSERT INTO meta(key,value) VALUES(?,?) ON CONFLICT(key) DO UPDATE SET value=excluded.value',
            (key, val)
        )

# ---------------------------------------------------------------------------
# Comandos
# ---------------------------------------------------------------------------

def cmd_scan(full_reset, dry_run):
    dir_pat, file_pat = load_gitignore_patterns(GITIGNORE_PATH)
    now_iso = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')

    added = updated = skipped = 0
    seen = set()

    if dry_run:
        print(f'[DRY-RUN] Raiz: {PROJECT_ROOT}')
        print(f'[DRY-RUN] Padrões dir: {len(dir_pat)}  ficheiro: {len(file_pat)}')
        for rel, abs_p in scan_files(PROJECT_ROOT, dir_pat, file_pat):
            size = os.path.getsize(abs_p)
            print(f'  {rel}  ({size:,} B)')
            added += 1
        print(f'[DRY-RUN] Total: {added} ficheiros')
        return

    conn = open_db(DB_PATH, full_reset)
    try:
        for rel, abs_p in scan_files(PROJECT_ROOT, dir_pat, file_pat):
            seen.add(rel)
            changed = upsert_file(conn, rel, abs_p, now_iso)
            if changed:
                added += 1
            else:
                skipped += 1

        removed = remove_stale(conn, seen)
        total = added + skipped
        update_meta(conn, PROJECT_ROOT, now_iso, total, len(dir_pat) + len(file_pat))
        conn.commit()
    finally:
        conn.close()

    label = 'FULL RESET' if full_reset else 'incremental'
    print(f'[{label}] {added} alterados, {skipped} inalterados, {removed} removidos — total {total}')
    print(f'DB: {DB_PATH}')


def cmd_stats():
    if not os.path.isfile(DB_PATH):
        print('project.index.db não encontrado. Execute sem --stats primeiro.')
        sys.exit(1)
    conn = sqlite3.connect(DB_PATH)
    try:
        rows = conn.execute(
            'SELECT extension, COUNT(*) AS n, SUM(size_bytes) AS bytes '
            'FROM files GROUP BY extension ORDER BY n DESC'
        ).fetchall()
        meta = dict(conn.execute('SELECT key, value FROM meta').fetchall())
    finally:
        conn.close()

    print(f"Raiz     : {meta.get('root', '?')}")
    print(f"Indexado : {meta.get('indexed_at', '?')}")
    print(f"Total    : {meta.get('total_files', '?')} ficheiros")
    print()
    print(f"{'Extensão':<16} {'Ficheiros':>10} {'Bytes':>14}")
    print('-' * 44)
    for ext, count, total_bytes in rows:
        print(f'{ext:<16} {count:>10,} {total_bytes or 0:>14,}')

# ---------------------------------------------------------------------------
# Entrada principal
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description='Gera/actualiza project.index.db com inventário de ficheiros do projecto.'
    )
    parser.add_argument('--full',    action='store_true', help='Drop + recreate (reset completo)')
    parser.add_argument('--stats',   action='store_true', help='Mostra contadores por extensão')
    parser.add_argument('--dry-run', action='store_true', help='Lista ficheiros sem escrever')
    args = parser.parse_args()

    if args.stats:
        cmd_stats()
    else:
        cmd_scan(full_reset=args.full, dry_run=args.dry_run)


if __name__ == '__main__':
    main()
