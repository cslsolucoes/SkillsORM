# dcclinux64 — Referência de Opções do Compilador

`dcclinux64.exe` é o compilador Delphi para Linux 64-bit (ELF64). Localização padrão:

```
C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\dcclinux64.exe
```

Uso: `dcclinux64 [opções] NomeProjeto.dpr`

---

## Opções de Compilação

### Controlo de Build

| Opção | Descrição | Exemplo |
|-------|-----------|---------|
| `-B` | Build completo (recompila todas as units, ignora DCUs existentes) | `-B` |
| `-M` | Make (recompila apenas units modificadas) | `-M` |
| `-GD` | Gerar ficheiro de debug (`.dSYM`) | `-GD` |
| `-Q` | Quiet — suprime mensagens normais, mostra apenas erros | `-Q` |
| `-V` | Verbose — detalha cada unit processada | `-V` |

### Optimização

| Opção | Nível | Descrição |
|-------|-------|-----------|
| `-O-` | 0 | Sem optimização (default em Debug) |
| `-O1` | 1 | Optimizações locais básicas |
| `-O2` | 2 | Optimizações globais (recomendado para Release) |
| `-O3` | 3 | Optimizações agressivas (pode aumentar tamanho do binário) |
| `-OR` | — | Optimização de registos |
| `-OS` | — | Optimização para tamanho (menor binário, pode ser mais lento) |

### Caminhos

| Opção | Descrição | Exemplo |
|-------|-----------|---------|
| `-U<path>` | Adicionar caminho de units (`.dcu`, `.pas`) | `-U/rtl/linux64/release` |
| `-I<path>` | Adicionar caminho de includes (`.inc`) | `-I../includes` |
| `-R<path>` | Adicionar caminho de recursos (`.res`) | `-R../resources` |
| `-N<path>` | Caminho de saída para `.dcu` gerados | `-N./obj` |
| `-E<path>` | Caminho de saída para o executável | `-E./bin` |
| `-LE<path>` | Caminho de saída para packages (`.so`) | `-LE/rtl` |
| `-LN<path>` | Caminho de pesquisa de packages (`.so`) | `-LN/rtl` |

### Namespaces e Units

| Opção | Descrição | Exemplo |
|-------|-----------|---------|
| `-NS<ns>` | Adicionar namespace de pesquisa de units | `-NSSystem;System.SysUtils;Posix` |
| `-U<unit>` | Adicionar unit ao uses implícito | (raro, ver dcc32 docs) |

**Namespaces mais usados para Linux:**
```
-NSSystem;System.SysUtils;System.Classes;System.IOUtils;Posix.Unistd;Posix.Signal;Posix.Fcntl;Posix.Stdlib
```

### Defines Condicionais

| Opção | Descrição | Exemplo |
|-------|-----------|---------|
| `-D<define>` | Adicionar define condicional | `-DLINUX;RELEASE;MY_FEATURE` |
| `-U<define>` | Remover define condicional (undefine) | `-UDEBUG` |

**Defines predefinidos pelo compilador (automáticos):**
- `LINUX` — plataforma Linux
- `LINUX64` — arquitectura 64-bit no Linux
- `POSIX` — sistema POSIX
- `CPU64BITS` — arquitectura 64-bit

### Compilação Condicional / Warnings

| Opção | Descrição | Exemplo |
|-------|-----------|---------|
| `-W<id>` | Desactivar warning específico | `-W1025` (deprecated symbol) |
| `-H` | Activar hints | `-H` |
| `-W` | Activar todos os warnings | `-W` |
| `-W-` | Desactivar todos os warnings | `-W-` |
| `-H-` | Desactivar todos os hints | `-H-` |

### Runtime e Linking

| Opção | Descrição | Exemplo |
|-------|-----------|---------|
| `-CG` | Activar verificações de overflow de inteiros | `-CG` |
| `-CR` | Activar verificações de range de arrays/strings | `-CR` |
| `-CO` | Activar verificação de overflow aritmético | `-CO` |
| `-CV` | Activar verificação de variantes | `-CV` |
| `-CX` | Activar verificação de overflow de inteiros de 64-bit | `-CX` |
| `-A<n>` | Alinhamento de dados em memória (1, 2, 4, 8, 16) | `-A8` |

### Debug

| Opção | Descrição |
|-------|-----------|
| `-GD` | Gerar informação de debug DWARF (para GDB e debugger remoto RAD Studio) |
| `-GL` | Gerar informação de linha para stack traces |
| `-GT` | Gerar informação de tipos (RTTI) completa |
| `-GP` | Activar profiling (gprof) |

---

## Exemplos Completos

### Build de Release optimizado

```bash
dcclinux64.exe \
  -B \
  -O2 \
  -Q \
  -NSSystem;System.SysUtils;System.Classes;Posix.Unistd;Posix.Signal \
  -U"C:\Program Files (x86)\Embarcadero\Studio\23.0\lib\Linux64\release" \
  -I"C:\Program Files (x86)\Embarcadero\Studio\23.0\include" \
  -E".\Linux64\Release" \
  -DRELEASE \
  MeuPrograma.dpr
```

### Build de Debug com símbolos

```bash
dcclinux64.exe \
  -B \
  -GD \
  -GL \
  -Q \
  -NSSystem;System.SysUtils;System.Classes;Posix.Unistd;Posix.Signal \
  -U"C:\Program Files (x86)\Embarcadero\Studio\23.0\lib\Linux64\debug" \
  -E".\Linux64\Debug" \
  -DDEBUG \
  MeuPrograma.dpr
```

### Build mínimo para CI/CD

```bash
SET DELPHI=C:\Program Files (x86)\Embarcadero\Studio\23.0

dcclinux64.exe -B -O2 -Q ^
  -NS"System;System.SysUtils;System.Classes" ^
  -U"%DELPHI%\lib\Linux64\release" ^
  -I"%DELPHI%\include" ^
  -E".\out" ^
  MeuPrograma.dpr

IF ERRORLEVEL 1 (
  ECHO Build falhou
  EXIT /B 1
)
```

---

## Códigos de Saída

| Código | Significado |
|--------|------------|
| 0 | Sucesso — binário gerado |
| 1 | Erros de compilação — nenhum binário gerado |
| 2 | Warnings fatais |
| outros | Erro interno do compilador |

---

## Diferenças vs dcc32/dcc64

| Aspecto | dcc32/dcc64 | dcclinux64 |
|---------|------------|------------|
| Output | PE (Windows) | ELF64 (Linux) |
| Extensão | `.exe` / `.dll` | sem extensão / `.so` |
| Units VCL | Suportadas | **Não suportadas** |
| Units FMX | Suportadas | **Não suportadas** (Linux FMX não existe) |
| Units Posix.* | Não disponíveis | **Obrigatórias** para syscalls |
| TService | Suportado (Vcl.SvcMgr) | **Não existe** — usar fork/setsid |
| Windows Registry | Suportado | **Não existe** — usar config files |
| AnsiString/WideString | Suportados | Suportados (Unicode padrão) |
