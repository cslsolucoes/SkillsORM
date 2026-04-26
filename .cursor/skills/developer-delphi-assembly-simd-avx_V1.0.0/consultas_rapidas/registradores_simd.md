# Registradores SIMD — Consulta Rapida

## Hierarquia de registradores

```
ZMM0  (512-bit) = YMM0 (bits 0-255) + bits 256-511
YMM0  (256-bit) = XMM0 (bits 0-127) + bits 128-255
XMM0  (128-bit) = 128 bits de dados
```

## Capacidade por tipo de dado

| Registrador | 32-bit float | 64-bit double | 8-bit byte | 16-bit | 32-bit int | 64-bit int |
| ----------- | ------------ | ------------- | ---------- | ------ | ---------- | ---------- |
| XMM (128)   | 4x           | 2x            | 16x        | 8x     | 4x         | 2x         |
| YMM (256)   | 8x           | 4x            | 32x        | 16x    | 8x         | 4x         |
| ZMM (512)   | 16x          | 8x            | 64x        | 32x    | 16x        | 8x         |

## Disponibilidade por extensao

| Extensao | Registradores | Quando disponivel (Intel)    |
| -------- | ------------- | ----------------------------- |
| SSE      | XMM0-XMM7    | Pentium III (1999)            |
| SSE2     | XMM0-XMM7    | Pentium 4 (2001)              |
| x64      | XMM0-XMM15   | x64 mode (registradores extras)|
| AVX      | YMM0-YMM15   | Sandy Bridge (2011)           |
| AVX2     | YMM0-YMM15   | Haswell (2013)                |
| AVX-512  | ZMM0-ZMM31   | Skylake-X (2017)              |

## Volatilidade Win64

| Registrador | Tipo          |
| ----------- | ------------- |
| XMM0-XMM5  | Volatile (pode destruir) |
| XMM6-XMM15 | NON-VOLATILE (preservar!) |
| YMM0-YMM15 | Parte volatile/non-volatile (bits 0-127 = XMM rule) |
| ZMM0-ZMM31 | Volatile (AVX-512 em Win64) |

## Win32: XMM sao todos caller-saved

No Win32, NAO ha XMM non-volatile — pode usar qualquer XMM livremente.
Isso NAO se aplica ao Win64!

## Sufixos de instrucao por tipo

| Sufixo | Tipo de dado          | Exemplo           |
| ------ | --------------------- | ----------------- |
| PS     | Packed Single (float) | ADDPS, MULPS      |
| PD     | Packed Double         | ADDPD, MULPD      |
| SS     | Scalar Single         | ADDSS (1 float)   |
| SD     | Scalar Double         | ADDSD (1 double)  |
| DQU    | Double Quadword Unaligned | MOVDQU          |
| DQA    | Double Quadword Aligned   | MOVDQA          |
