# Expressoes Assembly Delphi — Consulta Rapida

## Tabela de expressoes em tempo de compilacao

| Expressao                  | Retorna                                    | Exemplo resultado         |
| -------------------------- | ------------------------------------------ | ------------------------- |
| `OFFSET VarGlobal`         | Endereco estatico da variavel global       | Ponteiro constante        |
| `TYPE Integer`             | SizeOf(Integer) = 4                        | `MOV EAX, TYPE Integer`   |
| `TYPE Double`              | SizeOf(Double) = 8                         | `MOV EAX, TYPE Double`    |
| `TYPE TMyRecord`           | SizeOf(TMyRecord)                          | Varia com campos          |
| `SIZE VarArray`            | Tamanho total do array em bytes            | `SIZE arr` = Count * Elem |
| `SIZE VarSimples`          | SizeOf do tipo (igual ao TYPE)             | Para nao-array            |
| `VMTOFFSET T.Metodo`       | Offset do metodo virtual na VMT            | Inteiro positivo          |
| `DMTINDEX T.Metodo`        | Indice do metodo dynamic na DMT            | Inteiro NEGATIVO          |

## LEA — multiplicacoes sem MUL

| Expressao LEA                        | Calcula      | Ciclos vs IMUL |
| ------------------------------------ | ------------ | -------------- |
| `LEA EAX, [EAX*2]`                   | EAX * 2      | 1 vs 3-4       |
| `LEA EAX, [EAX*4]`                   | EAX * 4      | 1 vs 3-4       |
| `LEA EAX, [EAX*8]`                   | EAX * 8      | 1 vs 3-4       |
| `LEA EAX, [EAX + EAX*2]`            | EAX * 3      | 1              |
| `LEA EAX, [EAX + EAX*4]`            | EAX * 5      | 1              |
| `LEA EAX, [EAX + EAX*8]`            | EAX * 9      | 1              |
| `LEA ECX, [EAX*2]; LEA EAX, [ECX + EAX*4]` | EAX * 6 | 2         |
| `LEA ECX, [EAX*4]; LEA EAX, [ECX + EAX*2]` | EAX * 6 | 2         |

## Operadores em expressoes asm (calculados pelo compilador)

```pascal
asm
  // Aritmetica de constantes em tempo de compilacao:
  MOV EAX, TYPE Integer + 1      // EAX = 5
  MOV EAX, SIZE GArray SHR 2     // EAX = SIZE/4 = numero de elementos
  MOV EAX, TYPE TRegistro AND $0F // mascara dos 4 bits baixos
end;
```

## Acesso a elementos de array com escala

```pascal
// Equivale a: EAX = GArray[Indice]
// Indice em ECX:
asm
  MOV EAX, OFFSET GArray     // EAX = base
  MOV EAX, [EAX + ECX*4]     // EAX = GArray[Indice] (TYPE Integer = 4)
end;
```

## Diferenca VMTOFFSET vs DMTINDEX

| Aspecto          | VMTOFFSET                   | DMTINDEX                         |
| ---------------- | --------------------------- | -------------------------------- |
| Tipo de metodo   | `virtual`                   | `dynamic`                        |
| Valor retornado  | Offset positivo na VMT      | Indice negativo na DMT           |
| Uso em CALL      | `CALL [EAX + VMTOFFSET ...]`| Requer @DynamicDispatch          |
| Performance      | 1 deref de ponteiro         | Busca na tabela dinamica         |
| Uso recomendado  | Hot paths em asm            | Pouco usado em asm direto        |
