# Modificadores PTR — Referencia Rapida

## Modificadores de tamanho de acesso

| Modificador     | Tamanho   | Uso tipico                           |
| --------------- | --------- | ------------------------------------ |
| `BYTE PTR`      | 1 byte    | Ler/escrever Byte, Boolean           |
| `WORD PTR`      | 2 bytes   | Ler/escrever Word, SmallInt, WideChar|
| `DWORD PTR`     | 4 bytes   | Ler/escrever Integer, Cardinal, Single|
| `QWORD PTR`     | 8 bytes   | Ler/escrever Int64, Double           |
| `TBYTE PTR`     | 10 bytes  | Extended (FPU 80-bit)                |
| `XMMWORD PTR`   | 16 bytes  | XMM registers                        |
| `YMMWORD PTR`   | 32 bytes  | YMM registers                        |

## Quando PTR e obrigatorio

PTR e necessario quando o tamanho do acesso e AMBIGUO:
```pascal
asm
  MOV [EAX], 0      // AMBIGUO: quantos bytes? ERRO no assembler!
  MOV BYTE PTR [EAX], 0     // CORRETO: 1 byte
  MOV DWORD PTR [EAX], 0    // CORRETO: 4 bytes
end;
```

Nao e necessario quando o tamanho e obvio pelo registrador:
```pascal
asm
  MOV AL, [EAX]     // AL = 1 byte — sem PTR necessario
  MOV EAX, [EBX]    // EAX = 4 bytes — sem PTR necessario
  MOV RAX, [RBX]    // RAX = 8 bytes — sem PTR necessario
end;
```

## Leitura com extensao de sinal/zero

```pascal
asm
  // Zero-extend (preenche com zeros):
  MOVZX EAX, BYTE PTR [ESI]    // EAX = (Word)(Byte em [ESI])
  MOVZX EAX, WORD PTR [ESI]    // EAX = (DWord)(Word em [ESI])

  // Sign-extend (propaga sinal):
  MOVSX EAX, BYTE PTR [ESI]    // EAX = (Int32)(Int8 em [ESI])
  MOVSX EAX, WORD PTR [ESI]    // EAX = (Int32)(Int16 em [ESI])
  MOVSXD RAX, DWORD PTR [RBX]  // RAX = (Int64)(Int32 em [RBX]) [x64]
end;
```

## Acesso a campos de tipos Delphi

```pascal
type
  TRec = record
    ByteField:  Byte;     // offset 0
    WordField:  Word;     // offset 1 (ou 2 se alinhado)
    DWordField: Integer;  // offset varia
  end;

asm
  // Com PTR e offset manual:
  MOV AL,  BYTE PTR [EAX]        // ByteField
  MOV AX,  WORD PTR [EAX+2]     // WordField (apos alinhamento)
  MOV ECX, DWORD PTR [EAX+4]    // DWordField

  // Melhor: pelo nome do campo (Delphi calcula offset automaticamente):
  MOV AL,  [EAX].TRec.ByteField
  MOV AX,  [EAX].TRec.WordField
  MOV ECX, [EAX].TRec.DWordField
end;
```
