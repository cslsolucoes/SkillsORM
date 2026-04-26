#!/usr/bin/env python3
"""
Descompila ficheiros Microsoft Compiled HTML Help (.chm) para HTML — multiplataforma.

Backends (ordem em modo --backend auto):
  1) Windows: hh.exe -decompile (se existir) — resultado mais próximo do help oficial.
  2) 7-Zip em linha de comando: 7zz, 7z ou 7za no PATH; no Windows também procura
     em "Program Files\\7-Zip\\7z.exe".
  3) extract_chmLib (pacote chmlib em várias distribuições Linux).

Comportamento de pastas (igual ao decompile-chm.ps1):
  - Modo ficheiro: --chm-path → saída predefinida {stem}{suffix} junto ao .chm.
  - Modo lote: --chm-directory + --filter → cada foo.chm → foo{suffix}.

Dependências por SO:
  - Windows: hh.exe (já incluído) ou instalar 7-Zip.
  - Linux: sudo apt install p7zip-full (ou equivalente) e/ou chmlib-utils.
  - macOS: brew install p7zip (e opcionalmente chmlib via brew se disponível).

Uso:
  python3 decompile_chm.py --chm-path ./data.chm
  python3 decompile_chm.py --chm-directory ./Doc-Delphi --filter "delphi13-*.chm" --continue-on-error
  python3 decompile_chm.py --chm-path ./data.chm --backend 7z

internal_file_version: 1.1.0
Changelog:
  - 1.1.0 (10/04/2026): Multiplataforma — auto hh (Win) / 7z / extract_chmLib; --backend, --seven-zip-exe.
  - 1.0.0 (10/04/2026): Versão inicial — só Windows + hh.exe.
"""

from __future__ import annotations

import argparse
import fnmatch
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

DEFAULT_OUTPUT_SUFFIX = "_chm_decompiled"

BACKEND_AUTO = "auto"
BACKEND_HH = "hh"
BACKEND_7Z = "7z"
BACKEND_CHMLIB = "chmlib"


def _default_hh_exe() -> Path:
    root = os.environ.get("SystemRoot") or os.environ.get("WINDIR") or r"C:\Windows"
    return Path(root) / "hh.exe"


def _find_7z_executable(explicit: Path | None) -> str | None:
    if explicit is not None:
        e = explicit.expanduser()
        if e.is_file():
            return str(e.resolve())
        print(
            f"Aviso: --seven-zip-exe não é um ficheiro válido: {explicit}",
            file=sys.stderr,
        )
        return None
    for name in ("7zz", "7z", "7za"):
        w = shutil.which(name)
        if w:
            return w
    if platform.system() == "Windows":
        for env_key in ("ProgramFiles", "ProgramFiles(x86)"):
            base = os.environ.get(env_key)
            if not base:
                continue
            candidate = Path(base) / "7-Zip" / "7z.exe"
            if candidate.is_file():
                return str(candidate.resolve())
    return None


def _find_chmlib_executable() -> str | None:
    for name in ("extract_chmLib", "extract_chmlib"):
        w = shutil.which(name)
        if w:
            return w
    return None


def _resolve_backend(
    requested: str,
    hh_exe: Path,
    seven_zip_exe: Path | None,
) -> tuple[str, str]:
    """Devolve (tipo, caminho_comando) onde tipo ∈ {hh, 7z, chmlib}."""

    def need_hh() -> tuple[str, str]:
        if not hh_exe.is_file():
            print(f"Erro: hh.exe não encontrado: {hh_exe}", file=sys.stderr)
            sys.exit(2)
        return BACKEND_HH, str(hh_exe.resolve())

    def need_7z() -> tuple[str, str]:
        s = _find_7z_executable(seven_zip_exe)
        if not s:
            print(
                "Erro: executável 7-Zip (7zz/7z/7za) não encontrado. "
                "Instale p7zip / 7-Zip ou use --seven-zip-exe.",
                file=sys.stderr,
            )
            sys.exit(2)
        return BACKEND_7Z, s

    def need_chmlib() -> tuple[str, str]:
        e = _find_chmlib_executable()
        if not e:
            print(
                "Erro: extract_chmLib não encontrado no PATH. "
                "Instale chmlib-utils (Linux) ou use backend 7z.",
                file=sys.stderr,
            )
            sys.exit(2)
        return BACKEND_CHMLIB, e

    if requested == BACKEND_HH:
        return need_hh()
    if requested == BACKEND_7Z:
        return need_7z()
    if requested == BACKEND_CHMLIB:
        return need_chmlib()

    # auto
    if platform.system() == "Windows" and hh_exe.is_file():
        return BACKEND_HH, str(hh_exe.resolve())
    s = _find_7z_executable(seven_zip_exe)
    if s:
        return BACKEND_7Z, s
    e = _find_chmlib_executable()
    if e:
        return BACKEND_CHMLIB, e

    print(
        "Erro: nenhum backend disponível para descompilar .chm.\n"
        "  • Windows: confirme hh.exe em %SystemRoot%\\hh.exe ou instale 7-Zip.\n"
        "  • Linux: ex. sudo apt install p7zip-full\n"
        "  • macOS: ex. brew install p7zip\n"
        "Use --backend hh|7z|chmlib ou --seven-zip-exe para forçar.",
        file=sys.stderr,
    )
    sys.exit(2)


def _run_hh(hh: str, out_dir: Path, chm: Path) -> None:
    chm = chm.resolve()
    out_dir = Path(out_dir)
    out_dir.parent.mkdir(parents=True, exist_ok=True)
    out_dir.mkdir(parents=True, exist_ok=True)
    print(f"Decompilar (hh.exe): {chm} -> {out_dir}")
    r = subprocess.run(
        [hh, "-decompile", str(out_dir), str(chm)],
        check=False,
    )
    code = r.returncode if r.returncode is not None else 0
    if code != 0:
        raise RuntimeError(f"hh.exe terminou com código {code}")


def _run_7z(seven: str, out_dir: Path, chm: Path) -> None:
    chm = chm.resolve()
    out_dir = Path(out_dir).resolve()
    out_dir.parent.mkdir(parents=True, exist_ok=True)
    out_dir.mkdir(parents=True, exist_ok=True)
    # 7-Zip: -o sem espaço antes do caminho
    o_arg = f"-o{out_dir}"
    print(f"Decompilar (7-Zip): {chm} -> {out_dir}")
    r = subprocess.run(
        [seven, "x", "-y", "-bb0", o_arg, str(chm)],
        check=False,
    )
    code = r.returncode if r.returncode is not None else 0
    if code != 0:
        raise RuntimeError(f"7-Zip terminou com código {code}")


def _run_chmlib(exe: str, out_dir: Path, chm: Path) -> None:
    chm = chm.resolve()
    out_dir = Path(out_dir).resolve()
    out_dir.parent.mkdir(parents=True, exist_ok=True)
    if out_dir.exists():
        if any(out_dir.iterdir()):
            raise RuntimeError(
                f"Pasta de saída não está vazia (extract_chmLib): {out_dir}"
            )
        out_dir.rmdir()
    print(f"Decompilar (extract_chmLib): {chm} -> {out_dir}")
    r = subprocess.run([exe, str(chm), str(out_dir)], check=False)
    code = r.returncode if r.returncode is not None else 0
    if code != 0:
        raise RuntimeError(f"extract_chmLib terminou com código {code}")


def _run_extract(kind: str, tool: str, out_dir: Path, chm: Path) -> None:
    if kind == BACKEND_HH:
        _run_hh(tool, out_dir, chm)
    elif kind == BACKEND_7Z:
        _run_7z(tool, out_dir, chm)
    elif kind == BACKEND_CHMLIB:
        _run_chmlib(tool, out_dir, chm)
    else:
        raise ValueError(f"backend desconhecido: {kind}")


def _collect_chm_files(directory: Path, filter_pattern: str) -> list[Path]:
    filt = filter_pattern.lower()
    out: list[Path] = []
    for p in sorted(directory.iterdir()):
        if not p.is_file():
            continue
        if p.suffix.lower() != ".chm":
            continue
        if not fnmatch.fnmatch(p.name.lower(), filt):
            continue
        out.append(p)
    return out


def main() -> int:
    p = argparse.ArgumentParser(
        description="Descompila .chm para HTML (Windows: hh.exe; todos os SO: 7-Zip ou chmlib).",
    )
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument(
        "--chm-path",
        type=Path,
        metavar="PATH",
        help="Caminho de um único ficheiro .chm.",
    )
    g.add_argument(
        "--chm-directory",
        type=Path,
        metavar="DIR",
        help="Pasta com um ou mais .chm (modo lote).",
    )
    p.add_argument(
        "--filter",
        default="*.chm",
        help="Com --chm-directory: padrão tipo glob (predefinição: %(default)s).",
    )
    p.add_argument(
        "--output-directory",
        type=Path,
        metavar="DIR",
        help="Apenas com --chm-path: pasta de saída explícita.",
    )
    p.add_argument(
        "--output-suffix",
        default=DEFAULT_OUTPUT_SUFFIX,
        help=f"Sufixo da pasta derivada do nome (predefinição: {DEFAULT_OUTPUT_SUFFIX!r}).",
    )
    p.add_argument(
        "--backend",
        choices=(BACKEND_AUTO, BACKEND_HH, BACKEND_7Z, BACKEND_CHMLIB),
        default=BACKEND_AUTO,
        help="Motor: auto (hh no Windows se existir, senão 7z, senão chmlib), hh, 7z ou chmlib.",
    )
    p.add_argument(
        "--hh-exe",
        type=Path,
        default=_default_hh_exe(),
        help="Caminho para hh.exe (predefinição: %%SystemRoot%%\\hh.exe). Só usado com --backend hh ou auto.",
    )
    p.add_argument(
        "--seven-zip-exe",
        type=Path,
        default=None,
        metavar="PATH",
        help="Caminho explícito para 7zz/7z/7za (opcional).",
    )
    p.add_argument(
        "--continue-on-error",
        action="store_true",
        help="Modo lote: continua após falhas; código 1 se alguma falhar.",
    )

    args = p.parse_args()
    kind, tool = _resolve_backend(
        args.backend,
        Path(args.hh_exe),
        args.seven_zip_exe,
    )

    suffix: str = args.output_suffix

    if args.chm_path is not None:
        chm = args.chm_path
        if not chm.is_file():
            print(f"Erro: ficheiro .chm não encontrado: {chm}", file=sys.stderr)
            return 1
        if chm.suffix.lower() != ".chm":
            print(f"Aviso: extensão não é .chm: {chm}", file=sys.stderr)
        chm = chm.resolve()
        if args.output_directory is not None:
            out = args.output_directory
        else:
            out = chm.parent / f"{chm.stem}{suffix}"
        try:
            _run_extract(kind, tool, out, chm)
        except RuntimeError as e:
            print(f"Erro: {e}", file=sys.stderr)
            return 1
        print("Concluído (1 ficheiro).")
        return 0

    if args.output_directory is not None:
        print(
            "Erro: --output-directory só é válido com --chm-path.",
            file=sys.stderr,
        )
        return 2

    d = args.chm_directory
    if not d.is_dir():
        print(f"Erro: pasta não encontrada: {d}", file=sys.stderr)
        return 1
    d = d.resolve()
    files = _collect_chm_files(d, args.filter)
    if not files:
        print(
            f"Aviso: nenhum .chm encontrado em {d} com filtro {args.filter!r}.",
            file=sys.stderr,
        )
        return 0

    failed = 0
    for f in files:
        out = f.parent / f"{f.stem}{suffix}"
        try:
            _run_extract(kind, tool, out, f)
        except RuntimeError as e:
            failed += 1
            print(f"Aviso: {e}", file=sys.stderr)
            if not args.continue_on_error:
                return 1

    if failed:
        print(f"Aviso: terminado com {failed} falha(s).", file=sys.stderr)
        return 1
    print(f"Concluído ({len(files)} ficheiro(s)).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
