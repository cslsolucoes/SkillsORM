# NEAR, FAR e Modelo de Memoria — Consulta Rapida

## Contexto historico

No DOS/Windows 16-bit, havia modelos de memoria com segmentos:
- **NEAR pointer (16-bit):** offset apenas (CS:offset) — dentro do mesmo segmento
- **FAR pointer (16-bit):** segmento:offset — entre segmentos diferentes

## Delphi moderno (Win32/Win64): flat memory model

Em Win32 e Win64, Delphi usa **modelo flat** — enderecamento linear:
- Todos os ponteiros sao `NEAR` (offset de 32-bit no Win32, 64-bit no Win64)
- NAO existe conceito de segmento real no codigo moderno
- `FAR` e legado — ignorado pelo compilador atual

## NEAR e FAR em chamadas asm modernas

No built-in assembler Delphi, `CALL` e sempre NEAR (relativo):
```pascal
asm
  CALL @MinhaRotina    // NEAR CALL (near por default em flat mode)
  // FAR CALL: nao suportado em flat model moderno
end;
```

## RET vs RET FAR

```pascal
asm
  RET     // retorno normal (near) — obrigatorio no flat model
  RETF    // retorno far — NAO usar em Win32/Win64 moderno!
end;
```

## Ponteiros em Win32 vs Win64

| Aspecto         | Win32 (dcc32)  | Win64 (dcc64)  |
| --------------- | -------------- | -------------- |
| Tamanho Pointer | 4 bytes (EAX)  | 8 bytes (RAX)  |
| NativeUInt      | 4 bytes        | 8 bytes        |
| NativeInt       | 4 bytes        | 8 bytes        |
| PChar           | 4 bytes (EAX)  | 8 bytes (RAX)  |

## Uso de NativeUInt em assembly portavel

```pascal
// Para codigo portavel Win32/Win64:
procedure ProcessarBuffer(P: Pointer; Count: NativeUInt);
asm
{$IFDEF WIN32}
  // P=EAX, Count=EDX
  MOV ESI, EAX
{$ENDIF WIN32}
{$IFDEF WIN64}
  // P=RCX, Count=RDX
  MOV RSI, RCX
{$ENDIF WIN64}
end;
```
