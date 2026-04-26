# virtual vs dynamic (DMT) — Diferença e Quando Usar

## O que são

| | `virtual` | `dynamic` |
|---|-----------|-----------|
| Tabela usada | VMT (Virtual Method Table) | DMT (Dynamic Method Table) |
| Dispatch | O(1) — índice direto na VMT | O(n) — busca na hierarquia |
| Memória | 1 entrada por método na VMT de cada classe | Só armazena o método nas classes que sobrescrevem |
| Uso | Quase sempre | Só quando há *muitos* métodos raramente sobrescritos |

## Quando usar `virtual`

**Use virtual em quase todos os casos.** Dispatch é O(1), memória extra é negligenciável.

```pascal
type
  TAnimal = class
    procedure FazerSom; virtual; abstract;  // virtual
    procedure Mover;    virtual;             // virtual com implementação padrão
  end;
```

## Quando usar `dynamic`

Apenas quando:
- A classe define **dezenas de métodos opcionais** (ex.: event handlers)
- A maioria das subclasses **não** sobrescreve esses métodos
- Economia de memória na VMT é crítica (sistemas embedded, muitas classes)

```pascal
type
  TControl = class
    procedure OnClick;   dynamic; // raramente sobrescrito → economiza VMT
    procedure OnMouseDown; dynamic;
    procedure OnMouseUp;   dynamic;
    // ... dezenas de eventos ...
  end;
```

**O VCL usa `dynamic` para event handlers** (OnClick, OnMouseMove, etc.) exatamente por este motivo.

## `abstract` — obrigar subclasse a implementar

```pascal
type
  TForma = class abstract
    function Area: Double; virtual; abstract; // subclasse DEVE sobrescrever
  end;

  TCirculo = class(TForma)
    function Area: Double; override; // obrigatório
  end;
```

Se não sobrescrever método abstract: `EAbstractError` em runtime (aviso em compilação).

## `final` — impedir sobrescrita

```pascal
type
  TBase = class
    procedure Processo; virtual; final; // não pode ser sobrescrito
  end;
```

## override vs reintroduce

```pascal
type
  TBase = class
    procedure Metodo; virtual;
  end;

  TFilho = class(TBase)
    procedure Metodo; override;    // correto: sobrescreve o virtual
    // procedure Metodo; reintroduce; // ERRADO aqui — esconde, não sobrescreve
  end;

  TOutro = class(TBase)
    procedure OutroNome; virtual;  // novo método com mesmo nome → usa reintroduce
    procedure Metodo; reintroduce; // esconde TBase.Metodo (NÃO é polimórfico!)
  end;
```

**`reintroduce` esconde sem polimorfismo** — chamar via variável de TBase chamará TBase.Metodo, não TOutro.Metodo.

## Regra prática

```
virtual  → padrão para todos os métodos sobrescritíveis
dynamic  → apenas para event handlers (dezenas de opcionais)
abstract → quando subclasse DEVE implementar
final    → quando sobrescrita causaria comportamento incorreto
override → sempre que sobrescrever virtual/dynamic
```
