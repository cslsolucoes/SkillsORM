# Hierarquia RTTI em Delphi

## Árvore de herança

```
TRttiObject (base)
├── TRttiType
│   ├── TRttiInstanceType     ← classes (TClass)
│   ├── TRttiInterfaceType    ← interfaces
│   ├── TRttiEnumerationType  ← enums
│   ├── TRttiOrdinalType      ← Integer, Byte, Boolean
│   ├── TRttiFloatType        ← Single, Double, Extended
│   ├── TRttiStringType       ← string types
│   ├── TRttiArrayType        ← array estático
│   ├── TRttiDynamicArrayType ← TArray<T>
│   └── TRttiRecordType       ← record
│
└── TRttiMember
    ├── TRttiField       ← campos (FNome, FIdade)
    ├── TRttiProperty    ← properties (Nome, Idade)
    └── TRttiMethod      ← métodos (Salvar, Calcular)
        └── TRttiParameter ← parâmetros dos métodos
```

## Ponto de entrada: TRttiContext

```pascal
var Ctx := TRttiContext.Create;   // NÃO é referência — é record
try
  var Tipo := Ctx.GetType(TMinhaClasse);           // por TClass
  var Tipo2 := Ctx.GetType(TypeInfo(TMinhaClasse)); // por PTypeInfo
  var Tipo3 := Ctx.FindType('NomeDaUnit.TMinhaClasse'); // por nome qualificado
finally
  Ctx.Free; // libera cache interno — sempre usar try/finally
end;
```

## TRttiType — métodos principais

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `GetProperties` | `TArray<TRttiProperty>` | Todas as props (herda também) |
| `GetProperty(nome)` | `TRttiProperty` | Prop por nome (nil se não existe) |
| `GetMethods` | `TArray<TRttiMethod>` | Todos os métodos |
| `GetMethod(nome)` | `TRttiMethod` | Método por nome |
| `GetFields` | `TArray<TRttiField>` | Campos declarados |
| `GetAttributes` | `TArray<TCustomAttribute>` | Atributos da classe |
| `BaseType` | `TRttiType` | Tipo pai (nil para TObject) |
| `Name` | `string` | Nome curto (`TMinhaClasse`) |
| `QualifiedName` | `string` | Nome qualificado com unit |

## TRttiProperty — propriedades chave

| Membro | Descrição |
|--------|-----------|
| `Name` | Nome da propriedade |
| `PropertyType` | `TRttiType` do tipo da propriedade |
| `Visibility` | `TMemberVisibility` (mvPrivate..mvPublished) |
| `IsWritable` | True se tem setter |
| `IsReadable` | True se tem getter |
| `GetValue(Instance)` | Lê valor como `TValue` |
| `SetValue(Instance, Val)` | Escreve valor de `TValue` |
| `GetAttributes` | Atributos da propriedade |

## TRttiMethod — propriedades chave

| Membro | Descrição |
|--------|-----------|
| `Name` | Nome do método |
| `ReturnType` | `TRttiType` do retorno (nil = procedure) |
| `GetParameters` | `TArray<TRttiParameter>` |
| `IsClassMethod` | True para `class procedure/function` |
| `IsConstructor` | True para `constructor` |
| `IsDestructor` | True para `destructor` |
| `Invoke(Instance, Params)` | Invoca o método; retorna `TValue` |
| `Visibility` | Visibilidade do método |

## TMemberVisibility — filtros típicos

```pascal
// Só membros acessíveis externamente
if Prop.Visibility < mvPublic then Continue;

// Valores:
// mvPrivate = 0, mvProtected = 1, mvPublic = 2, mvPublished = 3
```

## TRttiParameter

```pascal
for Param in Metodo.GetParameters do
begin
  Writeln(Param.Name);          // nome do parâmetro
  Writeln(Param.ParamType.Name); // tipo do parâmetro
  // Param.Flags: pfConst, pfVar, pfOut, pfArray
end;
```

## Quando RTTI está disponível

- `{$M+}` ou classes com `published` habilitam RTTI para a classe
- Classes que herdam de `TPersistent` têm RTTI automático
- `{$RTTI EXPLICIT FIELDS([...]) METHODS([...]) PROPERTIES([...])}` controla granularidade
- Por padrão, `public` e `published` são visíveis; `private`/`protected` dependem de `{$RTTI}`
