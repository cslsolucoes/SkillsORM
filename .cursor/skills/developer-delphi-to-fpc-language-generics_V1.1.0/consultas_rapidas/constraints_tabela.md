# Constraints de Generics em Delphi

## Tabela completa de constraints

| Constraint | Sintaxe | Semântica | Habilitado |
|-----------|---------|-----------|-----------|
| `class` | `<T: class>` | T deve ser tipo referência (descende de TObject) | `T.Free`, `T = nil` |
| `record` | `<T: record>` | T deve ser tipo valor (record/set/enum/integer...) | sem `nil`, stack-allocated |
| `constructor` | `<T: constructor>` | T deve ter `constructor Create` sem parâmetros | `T.Create` na factory |
| interface | `<T: IFoo>` | T deve implementar IFoo | cast para IFoo seguro |
| base class | `<T: TBase>` | T deve ser TBase ou descendente | acesso a membros de TBase |
| combinados | `<T: class, constructor>` | T é objeto E pode ser criado | TObjectFactory<T> |

## Exemplos de cada constraint

### class
```pascal
type TCache<T: class> = class
  function Obter(const AChave: string): T;  // pode retornar nil
end;
```

### record
```pascal
type TCalc<T: record> = record
  // T nunca é nil; pode ser copiado com :=
end;
```

### constructor
```pascal
type TFabrica<T: class, constructor> = class
  function Criar: T;
begin
  Result := T.Create;  // sem constructor: erro de compilação
end;
```

### interface constraint
```pascal
type IDisposable = interface ['{GUID}'] procedure Dispose; end;

type TScoped<T: IDisposable> = class
  destructor Destroy; override;
begin
  FRecurso.Dispose;  // seguro pois T implementa IDisposable
end;
```

### base class
```pascal
type TAnimal = class
  procedure FazerSom; virtual; abstract;
end;

type TZoo<T: TAnimal, constructor> = class
  function AdicionarAnimal: T;
begin
  Result := T.Create;    // T.Create disponível (constructor)
  Result.FazerSom;       // FazerSom disponível (TAnimal)
end;
```

### Combinados: class + constructor + interface
```pascal
type
  IValidavel = interface ['{GUID}'] function EhValido: Boolean; end;

  TFactory<T: class, constructor, IValidavel> = class
    function CriarValido: T;
  end;
```

## Restrições e comportamentos

- **Só um constraint `record` ou `class`** por vez (mutuamente exclusivos)
- **`constructor`** implica `class` — não é preciso escrever ambos (mas é comum ver os dois para clareza)
- **Interfaces** não precisam de GUID para ser usadas como constraint
- **Tipos primitivos** (`Integer`, `Double`) satisfazem `record` mas não `class`
- **Sem constraint**: T é tratado como `TObject` — sem Free, sem Create, comparação restrita

## Erros comuns

```pascal
// ERRO: tentar chamar T.Create sem constructor constraint
type TFoo<T: class> = class
  function Criar: T;
  begin Result := T.Create; end  // ERRO de compilação!
end;

// CORRETO:
type TFoo<T: class, constructor> = class ...

// ERRO: passar Integer onde espera class constraint
var C: TCache<Integer>;  // Integer não é class!

// CORRETO:
var C: TCache<TStringList>;  // TStringList descende de TObject
```
