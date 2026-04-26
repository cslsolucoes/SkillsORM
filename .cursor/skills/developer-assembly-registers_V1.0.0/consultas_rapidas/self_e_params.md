# Self e parâmetros nos registradores — Como chegam no asm

## Delphi 32-bit — Convenção "register"

### Função livre (não é método)

```pascal
function MinhaFuncao(P1, P2, P3: Integer): Integer;
// EAX = P1
// EDX = P2
// ECX = P3
// 4° param em diante: [EBP+8], [EBP+12], ...
// Retorno: EAX
```

### Método de objeto/classe

```pascal
type TObj = class
  procedure Metodo(P1, P2: Integer);
end;

procedure TObj.Metodo(P1, P2: Integer);
// EAX = Self (ponteiro para o objeto — SEMPRE é o 1° slot)
// EDX = P1  (parâmetro 1 deslocado para o 2° slot)
// ECX = P2  (parâmetro 2 no 3° slot)
// Retorno de função: EAX
```

### Acesso a campos via Self (EAX)

```pascal
type TObj = class
  FX: Integer;  // offset 4 (VMT ptr ocupa os primeiros 4 bytes)
  FY: Integer;  // offset 8
end;

function TObj.GetX: Integer;
asm
  MOV EAX, [EAX].TObj.FX    // usa nome do campo — Delphi resolve o offset
end;

// Equivalente manual (frágil — prefira o nome do campo):
// MOV EAX, [EAX + 4]
```

## Delphi 64-bit — Windows x64 ABI

### Função livre

```pascal
function MinhaFuncao(P1, P2, P3, P4: Int64): Int64;
// RCX = P1
// RDX = P2
// R8  = P3
// R9  = P4
// 5°+ param: stack [RSP+40] (após RSP+32 de shadow space)
// Retorno: RAX (inteiro) ou XMM0 (float)
```

### Método de objeto/classe (64-bit)

```pascal
type TObj = class
  procedure Metodo(P1, P2, P3: Int64);
end;

procedure TObj.Metodo(P1, P2, P3: Int64);
// RCX = Self      ← Self ocupa o 1° slot
// RDX = P1        ← parâmetros deslocados
// R8  = P2
// R9  = P3
```

### Acesso a campos via Self (RCX) em 64-bit

```pascal
type TObj64 = class
  FValor: Int64;  // offset 8 em 64-bit (VMT ptr ocupa 8 bytes)
end;

function TObj64.GetValor: Int64;
asm
  {$IFDEF CPUX64}
  MOV RAX, [RCX].TObj64.FValor    // usa nome do campo
  {$ELSE}
  MOV EAX, [EAX].TObj64.FValor
  {$ENDIF}
end;
```

## Diagrama visual — 32-bit

```
Chamador chama: Obj.Metodo(10, 20, 30);
                   ↓
                EAX = @Obj  (Self)
                EDX = 10    (P1)
                ECX = 20    (P2)
                [stack] = 30 (P3 — 4° slot)
```

## Diagrama visual — 64-bit

```
Chamador chama: Obj.Metodo(10, 20, 30);
                   ↓
                RCX = @Obj  (Self)
                RDX = 10    (P1)
                R8  = 20    (P2)
                R9  = 30    (P3)
```

## Retorno de struct grande

Se a função retorna um registro/struct maior que 8 bytes (32-bit) ou maior que 16 bytes (64-bit),
o chamador aloca espaço e passa o ponteiro como argumento implícito adicional:

```pascal
// 32-bit: ponteiro de retorno em EAX se retorno > 8 bytes
// 64-bit: ponteiro de retorno em RCX, Self vai para RDX
// (o compilador gerencia isso automaticamente — conhecimento útil para debug)
```
