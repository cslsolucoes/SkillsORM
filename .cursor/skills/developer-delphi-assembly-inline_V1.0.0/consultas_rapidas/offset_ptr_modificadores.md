# OFFSET, PTR e Modificadores de Acesso — Consulta Rapida

## OFFSET — endereco de simbolo global

```pascal
var
  GVar: Integer = 42;

asm
  MOV EAX, OFFSET GVar     // EAX = endereco estatico de GVar
  MOV EAX, [EAX]           // EAX = valor de GVar (deref)

  // Forma mais simples (Delphi resolve):
  LEA EAX, GVar            // LEA tambem funciona para globals
end;
```

**Limitacao:** `OFFSET` so funciona com variaveis globais (secao .data).
Para variaveis locais, usar o nome diretamente (Delphi resolve para [EBP-N]).

## PTR — especificador de tamanho de acesso

```pascal
asm
  // Sem PTR: tamanho ambiguo
  // MOV [EAX], 0  // ERRO: ambiguo — quantos bytes?

  // Com PTR: explicito
  MOV BYTE PTR [EAX], 0      // gravar 1 byte
  MOV WORD PTR [EAX], 0      // gravar 2 bytes
  MOV DWORD PTR [EAX], 0     // gravar 4 bytes
  MOV QWORD PTR [EAX], 0     // gravar 8 bytes (x64 ou com XMM)

  // Ler com PTR:
  MOVZX EAX, BYTE PTR [EDI]  // EAX = zero-extended byte
  MOVSX EAX, WORD PTR [ESI]  // EAX = sign-extended word
end;
```

## TYPE — tamanho de tipo em bytes (compilacao)

```pascal
asm
  MOV EAX, TYPE Integer      // EAX = 4
  MOV EAX, TYPE Double       // EAX = 8
  MOV EAX, TYPE Byte         // EAX = 1
  MOV EAX, TYPE TMyRecord    // EAX = SizeOf(TMyRecord)
end;
```

## SIZE — tamanho total de variavel (inclui arrays)

```pascal
var
  Arr: array[0..9] of Integer;  // 10 elementos * 4 = 40 bytes
asm
  MOV EAX, SIZE Arr    // EAX = 40 (tamanho TOTAL)
  MOV EAX, TYPE Arr    // EAX = 4  (tamanho de 1 ELEMENTO)
end;
```

## VMTOFFSET — offset de metodo na VMT (Virtual Method Table)

```pascal
type
  TBase = class
    procedure MetodoVirtual; virtual;
  end;

// Chamar metodo virtual via VMT offset:
asm
  MOV EAX, Objeto                            // EAX = ponteiro do objeto
  MOV ECX, [EAX]                             // ECX = ponteiro para VMT
  CALL DWORD PTR [ECX + VMTOFFSET TBase.MetodoVirtual]
  // Equivalente a: Objeto.MetodoVirtual; mas sem lookup pelo nome
end;
```

## DMTINDEX — indice para metodo `dynamic`

```pascal
type
  TBase = class
    procedure MetodoDynamic; dynamic;
  end;

// Metodos dynamic usam DMT (Dynamic Method Table) com indices negativos
// DMTIndex e usado para dispatch via System.@DynamicDispatch
asm
  MOV EAX, DMTINDEX TBase.MetodoDynamic
  // Valor negativo — indice na DMT do objeto
end;
```
