# AVX-512 no Delphi — Sintaxe Angle Brackets — Consulta Rapida

## PROBLEMA FUNDAMENTAL

Em NASM e Intel syntax padrao, masking AVX-512 usa chaves:
```nasm
VADDPS ZMM0 {k1}{z}, ZMM1, ZMM2    ; NASM syntax
```

Em Delphi, chaves `{ }` sao COMENTARIOS Pascal! O parser ignora tudo entre `{` e `}`.
Por isso, o Delphi built-in assembler usa **angle brackets `< >`**:
```pascal
asm
  VADDPS ZMM0 <k1><z>, ZMM1, ZMM2   // Delphi syntax — CORRETO!
end;
```

## Tabela de conversao NASM → Delphi

| NASM (Intel)                         | Delphi built-in assembler              |
| ------------------------------------ | -------------------------------------- |
| `VADDPS ZMM0 {k1}{z}, ZMM1, ZMM2`  | `VADDPS ZMM0 <k1><z>, ZMM1, ZMM2`   |
| `VADDPS ZMM0 {k1}, ZMM1, ZMM2`     | `VADDPS ZMM0 <k1>, ZMM1, ZMM2`      |
| `VMOVAPS [RDI] {k1}, ZMM0`          | `VMOVAPS [RDI] <k1>, ZMM0`           |
| `VBROADCASTSS ZMM0, [RBX] {1to16}`  | `VBROADCASTSS ZMM0, [RBX] <1to16>`  |
| `VADDPS ZMM0, ZMM1, ZMM2 {rd-sae}` | `VADDPS ZMM0, ZMM1, ZMM2 <rd-sae>` |

## Tipos de masking

### Zeroing masking `<k1><z>`
Elementos onde K1=0 viram **zero**:
```pascal
asm
  VADDPS ZMM0 <k1><z>, ZMM1, ZMM2
  // Se K1[3]=0: ZMM0[3] = 0 (nao ZMM2[3]!)
end;
```

### Merge masking `<k1>` (sem z)
Elementos onde K1=0 ficam **inalterados** em ZMM0:
```pascal
asm
  VADDPS ZMM0 <k1>, ZMM1, ZMM2
  // Se K1[3]=0: ZMM0[3] fica como estava
end;
```

## Opmask registers K0-K7

```pascal
asm
  // Carregar mascara:
  MOV    EAX, $00FF      // 8 bits = 1, 8 bits = 0
  KMOVW  K1, EAX         // K1 = mascara de 16 elementos (float32)
  KMOVB  K2, EAX         // K2 = mascara de 8 elementos (float64)

  // Operacoes com mascara:
  KORW   K3, K1, K2      // K3 = K1 OR K2
  KANDW  K4, K1, K2      // K4 = K1 AND K2
  KNOT   K5, K1          // K5 = NOT K1

  // K0: sem masking (todos os elementos processados)
end;
```

## Broadcast scalars

```pascal
asm
  // Replicar um float para 16 posicoes de ZMM:
  VBROADCASTSS ZMM0, [RBX] <1to16>   // ZMM0 = {*RBX, *RBX, ..., *RBX} x16
  // Para AVX2 (8 floats):
  VBROADCASTSS YMM0, XMM0             // sem bracket
end;
```

## Rounding control embutido

```pascal
asm
  VADDPS ZMM0, ZMM1, ZMM2 <rn>   // round-to-nearest (default)
  VADDPS ZMM0, ZMM1, ZMM2 <rd>   // round-down (floor)
  VADDPS ZMM0, ZMM1, ZMM2 <ru>   // round-up (ceil)
  VADDPS ZMM0, ZMM1, ZMM2 <rz>   // round-to-zero (truncate)
end;
```
