# Assembly no Delphi — Cruzamentos e Restricoes — Consulta Rapida

## Onde o asm pode aparecer no codigo Delphi

| Local                              | Sintaxe                                | Skill      |
| ---------------------------------- | -------------------------------------- | ---------- |
| Dentro de funcao/procedure Pascal  | `asm ... end;` dentro de `begin...end`| J2         |
| Funcao inteiramente asm            | `function F: T; assembler; asm ... end;` | J3     |
| Arquivo .obj NASM linkado          | `{$L arq.obj}` + `external`           | J3         |
| DLL assembly externa               | `external 'lib.dll' name 'Func'`      | J1 + J3    |

## Plataformas suportadas pelo built-in assembler

| Plataforma         | Compilador  | asm..end | Comentario                      |
| ------------------ | ----------- | -------- | -------------------------------- |
| Windows x86 32-bit | dcc32       | SIM      | Suporte total                    |
| Windows x64 64-bit | dcc64       | SIM      | Pseudo-ops .PARAMS etc.          |
| macOS x64          | dcc64       | SIM      | Limitado                         |
| iOS ARM/ARM64      | dccios      | NAO      | Compilador LLVM — sem asm inline |
| Android ARM/ARM64  | dccaarm     | NAO      | Compilador LLVM — sem asm inline |
| Linux x64 (FPC)    | fpc         | SIM      | Sintaxe FPC (diferente Delphi)  |

## Tipos Delphi que NAO podem ser usados diretamente em asm

| Tipo                | Motivo                                    | Alternativa em asm              |
| ------------------- | ----------------------------------------- | -------------------------------- |
| `string` / `UnicodeString` | ARC/ref count corrompido se acessado | `PChar` / `PWideChar`      |
| `AnsiString`        | Idem                                      | `PAnsiChar`                     |
| `interface`         | COM ref count corrompido                  | Ponteiro raw (perigoso)          |
| `array dinamico`    | Ref count + descriptor de tamanho        | `PInteiro` / pointer tipado     |
| `Variant`           | Estrutura complexa de gerenciamento       | Extrair valor antes do bloco asm|

## Erros de compilacao mais comuns

| Erro   | Causa                                              |
| ------ | -------------------------------------------------- |
| E2426  | `inline` + `asm` combinados — incompativel         |
| E2003  | Label sem `@` conflitando com identificador Pascal |
| E2036  | `OFFSET` em variavel local (funciona so em global) |
| E1026  | `{$L arquivo.obj}` — arquivo .obj nao encontrado   |

## Convencoes de chamada por contexto Delphi

| Contexto                        | Convencao padrao | Self em       |
| ------------------------------- | ---------------- | ------------- |
| Funcao livre (Win32)            | `register`       | N/A           |
| Metodo de classe (Win32)        | `register`       | EAX           |
| WinAPI call                     | `stdcall`        | N/A           |
| COM interface                   | `safecall`       | N/A           |
| Funcao pura x64 (Win64)         | Win64 ABI        | N/A           |
| Metodo de classe (Win64)        | Win64 ABI        | RCX           |
