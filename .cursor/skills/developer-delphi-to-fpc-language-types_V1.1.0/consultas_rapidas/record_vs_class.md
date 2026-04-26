# Record vs Class — Valor vs Referência

## Diferença fundamental

| | Record | Class |
|---|--------|-------|
| Semântica | **Valor** (copiado na atribuição) | **Referência** (compartilhado) |
| Memória | Stack (variáveis locais) ou inline em outro record | Heap |
| Inicialização | Campos zerados ao entrar no escopo | Nil até `Create` |
| Destruição | Automática ao sair do escopo | Manual (`Free`) ou GC (ARC mobile) |
| Herança | Não (somente interfaces) | Sim |
| Nil | Impossível (record sempre existe) | Possível (referência nula) |
| Constructor | `class function` (factory) | `constructor Create` |
| RTTI | Limitada | Completa (via `published`) |

## Quando usar Record

```
✓ Dados simples sem comportamento complexo (DTO, VO, coordinate)
✓ Imutabilidade desejada por padrão (cópia = nova instância)
✓ Performance: evitar heap allocation em dados pequenos e frequentes
✓ Value semantics necessária (TPoint, TRGB, TRect, TRectF)
✓ Retorno de múltiplos valores de uma função
✓ Campos de um TList<T> sem overhead de ponteiro
```

## Quando usar Class

```
✓ Objetos com identidade (mesma referência em vários lugares)
✓ Ciclo de vida gerenciado (criar/destruir explicitamente)
✓ Herança e polimorfismo necessários
✓ Objetos grandes (evitar cópia custosa)
✓ Objetos que mantêm estado mutável compartilhado
✓ Implementar interfaces com reference counting (TInterfacedObject)
```

## Cópia por valor — cuidado

```pascal
// Record: CÓPIA
var A: TPoint := TPoint.Create(1, 2);
var B := A;      // B é uma cópia independente
B.X := 99;       // não afeta A
Writeln(A.X);    // 1 — inalterado

// Class: REFERÊNCIA
var Obj1 := TMinhaClasse.Create;
var Obj2 := Obj1;  // Obj2 aponta para o MESMO objeto
Obj2.Campo := 99;
Writeln(Obj1.Campo); // 99 — afetado!
```

## Parâmetros de função

```pascal
// Record: const evita cópia sem permitir modificação (recomendado)
procedure Calcular(const P: TPoint);

// Record: var permite modificação sem cópia
procedure Mover(var P: TPoint);

// Record: por valor = cópia (custosa para records grandes)
procedure Processar(P: TPoint);

// Class: sempre por referência (sem const/var = ponteiro copiado, não objeto)
procedure Salvar(Obj: TMinhaClasse); // ponteiro copiado, objeto compartilhado
```

## Record com campo de class

```pascal
// CUIDADO: record pode conter referência para classe
type
  TWrapper = record
    FObj: TStringList; // referência — não é copiada em profundidade!
  end;

var A, B: TWrapper;
A.FObj := TStringList.Create;
B := A;  // B.FObj aponta para O MESMO TStringList que A.FObj
B.FObj.Add('x'); // afeta também A.FObj!
```

## Regra de ouro

> Use **record** para dados puros (sem identidade, sem hierarquia).  
> Use **class** para entidades com comportamento, estado compartilhado ou herança.
