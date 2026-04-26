# Comparativo de Convencoes — Consulta Rapida

## Tabela mestre

| Convencao  | Args         | Pilha limpa | Retorno     | Variadic? | Uso tipico           |
| ---------- | ------------ | ----------- | ----------- | --------- | -------------------- |
| register   | EAX/EDX/ECX  | callee      | EAX/ST(0)  | Nao       | Delphi padrao Win32  |
| stdcall    | pilha R→L    | callee      | EAX         | Nao       | WinAPI, DLL Win32    |
| cdecl      | pilha R→L    | caller      | EAX         | Sim       | DLLs C/C++           |
| safecall   | pilha R→L    | callee      | HResult     | Nao       | COM, Automation      |
| pascal     | pilha L→R    | callee      | EAX         | Nao       | Legado Delphi 1-3    |
| winapi     | OS-dependente| OS-dep      | OS-dep      | Nao       | Portabilidade OS     |
| Win64 ABI  | RCX/RDX/R8/R9| caller      | RAX/XMM0   | Sim       | dcc64, WinAPI 64     |

## Quando escolher cada uma

| Situacao                                       | Convencao recomendada |
| ---------------------------------------------- | --------------------- |
| Funcao interna Delphi sem DLL                  | register (padrao)     |
| Exportar DLL para consumo em C/C++             | cdecl ou stdcall      |
| Chamar WinAPI do Windows.pas                   | stdcall (ja definido) |
| Interface COM/Automation                       | safecall              |
| DLL consumida por linguagem variada            | cdecl (mais universal)|
| Codigo x64 com dcc64                           | Win64 ABI automatico  |

## Nome decorado (name mangling)

| Convencao | Prefixo/sufixo NASM (Win32)        |
| --------- | ---------------------------------- |
| cdecl     | `_NomeFuncao`                      |
| stdcall   | `_NomeFuncao@N` (N=bytes da pilha) |
| fastcall  | `@NomeFuncao@N`                    |
| Win64     | `NomeFuncao` (sem decoracao)       |
