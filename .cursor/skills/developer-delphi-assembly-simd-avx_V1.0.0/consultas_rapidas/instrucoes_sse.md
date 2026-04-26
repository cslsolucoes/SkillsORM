# Instrucoes SSE/SSE2 Essenciais — Consulta Rapida

## Move (carregar/gravar)

| Instrucao       | Operacao                                       | Alinhamento |
| --------------- | ---------------------------------------------- | ----------- |
| `MOVAPS`        | Move 4 floats alinhados (16-byte aligned)      | 16 bytes    |
| `MOVUPS`        | Move 4 floats nao-alinhados                    | Qualquer    |
| `MOVSS`         | Move 1 float (scalar)                          | Qualquer    |
| `MOVAPD`        | Move 2 doubles alinhados                       | 16 bytes    |
| `MOVUPD`        | Move 2 doubles nao-alinhados                   | Qualquer    |
| `MOVDQA`        | Move 128-bit inteiros alinhados                | 16 bytes    |
| `MOVDQU`        | Move 128-bit inteiros nao-alinhados            | Qualquer    |

## Aritmetica Float (Packed = 4 floats)

| Instrucao  | Operacao                   |
| ---------- | -------------------------- |
| `ADDPS`    | XMM += XMM (4 somas)       |
| `SUBPS`    | XMM -= XMM (4 subtracoes)  |
| `MULPS`    | XMM *= XMM (4 mult.)       |
| `DIVPS`    | XMM /= XMM (4 divisoes)    |
| `SQRTPS`   | sqrt(XMM) (4 raizes)       |
| `MINPS`    | min(XMM, XMM) (4 mins)     |
| `MAXPS`    | max(XMM, XMM) (4 maxs)     |
| `RCPPS`    | 1/XMM aproximado (4 recip.)|
| `RSQRTPS`  | 1/sqrt(XMM) aprox.         |

## Aritmetica Inteira (SSE2)

| Instrucao  | Tipo           | Operacao                     |
| ---------- | -------------- | ----------------------------- |
| `PADDB`    | 16x Int8       | Soma com wrap                |
| `PADDW`    | 8x Int16       | Soma com wrap                |
| `PADDD`    | 4x Int32       | Soma com wrap                |
| `PADDQ`    | 2x Int64       | Soma com wrap                |
| `PSUBB/W/D/Q` | Int8-64    | Subtracao                    |
| `PMULLD`   | 4x Int32       | Multiplicacao (SSE4.1!)       |
| `PCMPEQD`  | 4x Int32       | Igualdade (mascara 0xFFFF ou 0)|
| `PCMPGTD`  | 4x Int32       | Maior-que (mascara)          |
| `PAND`     | 128-bit        | AND bitwise                  |
| `POR`      | 128-bit        | OR bitwise                   |
| `PXOR`     | 128-bit        | XOR bitwise                  |

## Shuffle/Blend (SSE/SSE2)

| Instrucao  | Operacao                                    |
| ---------- | ------------------------------------------- |
| `SHUFPS`   | Reordenar 4 floats (immediate control)      |
| `UNPCKLPS` | Intercalar 2 floats baixos de 2 XMMs        |
| `UNPCKHPS` | Intercalar 2 floats altos de 2 XMMs         |

## Exemplos rapidos

```pascal
asm
  // Soma de 4 floats em paralelo:
  MOVUPS XMM0, [ESI]    // carregar
  ADDPS  XMM0, XMM1     // somar
  MOVUPS [EDI], XMM0    // gravar

  // Zeros:
  XORPS  XMM0, XMM0     // XMM0 = 0.0, 0.0, 0.0, 0.0

  // Broadcast de um float para 4 posicoes:
  MOVSS  XMM0, [EBX]    // XMM0 = valor, 0, 0, 0
  SHUFPS XMM0, XMM0, 0  // XMM0 = valor, valor, valor, valor
end;
```
