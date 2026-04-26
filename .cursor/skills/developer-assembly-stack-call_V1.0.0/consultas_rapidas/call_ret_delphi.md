# CALL e RET no Delphi — Referência prática

## Formas de RET geradas pelo compilador Delphi

| Convenção | RET gerado | Quem limpa |
|-----------|------------|------------|
| register (32-bit) | `RET` | Caller (params em regs, sem stack) |
| stdcall (32-bit) | `RET N` | Callee (N = total bytes dos params) |
| cdecl (32-bit) | `RET` | Caller |
| safecall (32-bit) | `RET N` + result in EAX | Callee |
| Windows x64 (dcc64) | `RET` | Caller (shadow space alocado pelo caller) |

## Não emitir RET manualmente em blocos asm..end

O Delphi gera o epilogue correto automaticamente. Emitir `RET` manualmente causa:
- Saída prematura da função (sem restaurar EBP/RBP)
- Possível stack corruption
- Exceção de violação de acesso em runtime

```pascal
// ERRADO — não fazer:
function Errada: Integer;
asm
  MOV EAX, 42
  RET           // ERRADO! O Delphi vai gerar outro RET depois
end;

// CORRETO:
function Correta: Integer;
asm
  MOV EAX, 42
  // Sem RET — o Delphi gera o epilogue correto
end;
```

## Chamar função Delphi de dentro do asm

```pascal
procedure ChemarPascal;
var
  X, Y: Integer;
begin
  X := 10;
  asm
    // Chamar função com convenção register:
    MOV  EAX, X     // EAX = 1° parâmetro
    MOV  EDX, 5     // EDX = 2° parâmetro
    CALL MinhaFuncao // CALL direta usando o nome Pascal
    MOV  Y, EAX     // Y = resultado retornado em EAX

    // IMPORTANTE: após CALL, EAX, EDX, ECX podem ter sido destruídos
    // EBX, ESI, EDI, EBP foram preservados pelo callee
  end;
end;
```

## Registradores após CALL (o que esperar)

```
Após qualquer CALL a função Delphi (convenção register):
  EAX = resultado (se a função retornar valor)
  EDX = parte alta do Int64 (se retornar Int64 em 32-bit)
  EBX = preservado (garantido pela callee)
  ESI = preservado
  EDI = preservado
  EBP = preservado
  ECX = DESTRUÍDO (usado como 3° param e para outros fins)
  EDX = DESTRUÍDO (se a função não retorna Int64)
```

## Convenção de chamada x64 — código Delphi

```pascal
// Em dcc64, Delphi usa Windows x64 ABI automaticamente:
// - Caller aloca shadow space (compilador faz isso)
// - Parâmetros em RCX, RDX, R8, R9
// - Retorno em RAX ou XMM0

function MinhaFuncao64(A, B: Int64): Int64;
asm
  // RCX = A, RDX = B (Windows x64)
  MOV RAX, RCX
  ADD RAX, RDX
end;

// O compilador gera automaticamente:
// sub rsp, 32  (shadow space para chamadas internas)
// ...
// add rsp, 32
// ret
```

## Verificar tamanho do frame no CPU View

Para ver quanto espaço o Delphi reservou para o frame:

1. Colocar breakpoint dentro da função
2. Abrir CPU View
3. Observar o disassembly do prologue: `SUB ESP, N` ou `SUB RSP, N`
4. N = bytes reservados para variáveis locais + alinhamento
5. No painel Stack, ver os valores em [EBP-4], [EBP-8] etc.
