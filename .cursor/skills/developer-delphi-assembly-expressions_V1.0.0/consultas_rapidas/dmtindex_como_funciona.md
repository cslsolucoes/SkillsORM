# DMTINDEX — Como Funciona — Consulta Rapida

## Metodos `dynamic` vs `virtual` no Delphi

| Aspecto                | `virtual`              | `dynamic`                     |
| ---------------------- | ---------------------- | ----------------------------- |
| Tabela usada           | VMT                    | DMT (Dynamic Method Table)    |
| Indice                 | Offset positivo        | Indice negativo unico         |
| Espaco em subclasses   | Slot em CADA classe    | Apenas nas que sobrescrevem   |
| Performance dispatch   | Rapida (1 deref)       | Mais lenta (busca na DMT)     |
| Uso recomendado        | Hot paths, muitas class| Hierarquias extensas, raro    |

## Estrutura da DMT

```
DMT (embarcada no bloco de dados da VMT):
  DMT[-4] = numero de entradas
  DMT[-8] = {indice1, ponteiro1}
  DMT[-12] = {indice2, ponteiro2}
  ...
```

Cada metodo `dynamic` recebe um indice negativo UNICO (global ao programa).
O dispatch busca o metodo mais derivado que o implementa.

## DMTINDEX na pratica

```pascal
type
  TBase = class
    procedure DynProc; dynamic;
  end;

// O valor de DMTINDEX TBase.DynProc e um inteiro negativo (ex: -1, -2, ...)
// Este valor e gerado pelo compilador Delphi
asm
  MOV EAX, DMTINDEX TBase.DynProc   // EAX = indice negativo (-N)
end;
```

## Como chamar metodo dynamic via asm (avancado)

O dispatch dinamico usa a RTL do Delphi (`System.@DynamicDispatch`):
```pascal
// Nao e simples CALL [VMT + offset] como virtual!
// Para chamar DynProc no Obj:
asm
  // Convencao register: Obj em EAX
  MOV  EDX, DMTINDEX TBase.DynProc    // EDX = indice
  CALL System.@DynamicDispatch         // RTL busca na DMT do objeto
  // Self (EAX) e passado pelo caller
end;
```

## Recomendacao para codigo assembly

**Evite usar `dynamic` se voce precisa de dispatch via asm.**
Prefira `virtual` + `VMTOFFSET` — mais simples, previsivel e eficiente.

Use `dynamic` apenas quando:
- A hierarquia de heranca e muito grande
- Poucos descendentes sobrescrevem o metodo
- Performance de chamada nao e critica (o dispatch e mais lento)
