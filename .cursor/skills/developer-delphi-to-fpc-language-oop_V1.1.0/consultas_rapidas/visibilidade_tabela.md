# Visibilidade em Delphi — Tabela Completa

## Tabela de acesso

| Modificador | Própria classe | Mesma unit | Subclasse mesma unit | Subclasse outra unit | Fora |
|-------------|:--------------:|:----------:|:-------------------:|:--------------------:|:----:|
| `private` | ✓ | ✓ | ✓ | ✗ | ✗ |
| `strict private` | ✓ | ✗ | ✗ | ✗ | ✗ |
| `protected` | ✓ | ✓ | ✓ | ✓ | ✗ |
| `strict protected` | ✓ | ✗ | ✗ | ✓ | ✗ |
| `public` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `published` | ✓ | ✓ | ✓ | ✓ | ✓ + RTTI |

> **"Mesma unit"**: qualquer código no mesmo arquivo `.pas`, mesmo que seja outra classe.

## Quando usar cada um

```
strict private    → campos internos que só a própria classe deve tocar
                    evita que subclasses acessem acidentalmente
private           → campos acessíveis a outras classes na mesma unit
                    (DI interno, testes na mesma unit)
protected         → métodos/campos que subclasses precisam acessar
strict protected  → idem, mas blindado contra código na mesma unit
public            → API pública da classe
published         → properties expostas a RTTI (DFM, ORM, serialização)
```

## Exemplo prático

```pascal
type
  TCliente = class
  strict private
    FHashSenha: string;       // NUNCA visível fora da classe

  private
    FCache: TDictionary<string, string>; // utilitário interno da unit

  protected
    procedure DoSalvar; virtual; // subclasse pode especializar

  public
    constructor Create(const ANome: string);
    function Autenticar(const ASenha: string): Boolean;
    property Nome: string read FNome write FNome;

  published
    property Id: Integer read FId write FId;   // RTTI para ORM/serialização
    property Email: string read FEmail write FEmail;
  end;
```

## Armadilhas comuns

```pascal
// ARMADILHA: private em Delphi NÃO é como Java/C# — é "unit private"
// Isso COMPILA (outra classe na mesma unit):
type
  THelper = class
    procedure AcessarPrivado(A: TCliente);
    begin
      Writeln(A.FHashSenha); // COMPILA! (mesma unit)
    end;
  end;

// Para blindar completamente: usar strict private
```

## published vs public

```pascal
// public: sem RTTI automático
property Nome: string read FNome write FNome; // public

// published: gera TypeInfo + PropInfo — necessário para:
//   - Streaming DFM (designer Delphi)
//   - GetPropInfo / SetStrProp / GetStrProp
//   - ORMs que usam RTTI para mapeamento
//   - Serialização/deserialização por nome
property Email: string read FEmail write FEmail; // published — visível via RTTI
```
