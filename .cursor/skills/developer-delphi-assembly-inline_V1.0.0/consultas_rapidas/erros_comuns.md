# Erros Comuns em Assembly Inline Delphi — Consulta Rapida

## Erros de compilacao frequentes

| Erro      | Mensagem                                      | Causa                                  | Solucao                                |
| --------- | --------------------------------------------- | -------------------------------------- | -------------------------------------- |
| E2426     | Cannot inline assembler procedures            | `inline` + `asm` combinados            | Remover `inline;`                      |
| E2089     | Invalid typecast                              | Tamanho incorreto no PTR               | Verificar BYTE/WORD/DWORD PTR          |
| E2003     | Undeclared identifier                         | Label sem @ conflita com Pascal        | Adicionar @ no label                   |
| E2010     | Incompatible types                            | Tipo errado no operando                | Verificar tamanho dos registradores    |
| E2036     | Variable required                             | Tentou usar OFFSET em variavel local   | OFFSET so funciona em globais          |

## Bugs em runtime silenciosos

### Bug: EBX nao preservado
```pascal
function BugEbx(A: Integer): Integer;
asm
  MOV EBX, EAX    // ERRADO: EBX e callee-saved, nao salvo!
  // ... usa EBX ...
  MOV EAX, EBX
  // EBX do caller foi destruido — bug aparece em outro lugar
end;

// CORRETO:
function CorretoEbx(A: Integer): Integer;
asm
  PUSH EBX
  MOV  EBX, EAX
  // ... usa EBX ...
  MOV  EAX, EBX
  POP  EBX
end;
```

### Bug: acesso a string gerenciada
```pascal
// ERRADO: string tem ref count — acesso direto corrompe!
procedure BugString(const S: string);
asm
  MOV EAX, S       // EAX = ponteiro para string data
  MOV [EAX], 0    // PERIGO: modifica dados da string sem ref count!
end;

// CORRETO: usar variaveis nao-gerenciadas
procedure CorretoString(P: PChar; Len: Integer);
asm
  // P = PChar (ponteiro simples, sem gerenciamento)
  // Seguro manipular [EAX]
end;
```

### Bug: (* *) dentro de asm
```pascal
asm
  MOV EAX, 1   (* ESTE COMENTARIO QUEBRA O PARSER! *)
  // Usar apenas // ou { }
end;
```

### Bug: label sem @ conflitando
```pascal
asm
  JMP MinhaLabel   // ERRADO: Delphi pode confundir com identificador Pascal
MinhaLabel:        // pode ser interpretado como chamada de funcao Pascal!
end;

// CORRETO:
asm
  JMP @MinhaLabel
@MinhaLabel:
end;
```
