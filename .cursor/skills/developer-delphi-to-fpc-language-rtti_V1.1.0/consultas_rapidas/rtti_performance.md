# RTTI — Performance e Boas Práticas

## Custo relativo das operações RTTI

| Operação | Custo (relativo) | Nota |
|----------|-----------------|------|
| `TRttiContext.Create` | Baixo | Record — não aloca heap |
| `Ctx.GetType(TClasse)` | Médio (~µs) | Primeira chamada constrói cache |
| `Tipo.GetProperties` | Médio | Retorna array — aloca memória |
| `Tipo.GetProperty(nome)` | Baixo | Busca por nome no cache |
| `Prop.GetValue(instance)` | Médio (~100ns) | Acesso indireto via ponteiro |
| `Prop.SetValue(instance, val)` | Médio (~100ns) | Idem |
| `Metodo.Invoke(instance, params)` | Alto (~µs) | Invocação indireta + boxing |
| `Ctx.Free` | Baixo | Libera cache interno |

## Regra de ouro: cache o TRttiContext

```pascal
// MAL: criar/destruir em cada chamada (perde cache)
procedure Processar(Obj: TObject);
var Ctx: TRttiContext;
begin
  Ctx := TRttiContext.Create;
  try
    var Tipo := Ctx.GetType(Obj.ClassType);
    // ...
  finally
    Ctx.Free;  // perde o cache!
  end;
end;

// BOM: context compartilhado no nível do mapper/service
type
  TMapper = class
  private
    FCtx: TRttiContext;  // vive junto com o mapper
  public
    constructor Create;
    destructor Destroy; override;
    procedure Mapear(Obj: TObject);
  end;

constructor TMapper.Create;
begin
  inherited Create;
  FCtx := TRttiContext.Create;
end;

destructor TMapper.Destroy;
begin
  FCtx.Free;  // libera uma vez só
  inherited;
end;
```

## Cache de TRttiType e TRttiProperty

```pascal
// MAL: GetType + GetProperty em cada chamada
procedure Atualizar(Obj: TObject; const ANome: string; AVal: TValue);
var Ctx: TRttiContext;
begin
  Ctx := TRttiContext.Create;
  try
    Ctx.GetType(Obj.ClassType).GetProperty(ANome).SetValue(Obj, AVal);
  finally Ctx.Free; end;
end;

// BOM: pre-computar mapa de propriedades uma vez
type
  TMapaPropriedades = TDictionary<string, TRttiProperty>;

procedure PreComputar(AClass: TClass; var Ctx: TRttiContext;
  var Mapa: TMapaPropriedades);
begin
  Mapa := TMapaPropriedades.Create;
  for var Prop in Ctx.GetType(AClass).GetProperties do
    Mapa.Add(Prop.Name, Prop);
end;
// Depois: Mapa['Nome'].SetValue(Obj, Val) — sem GetType em cada chamada
```

## Quando NÃO usar RTTI

- Em hot loops (>10.000 iterações por frame/tick)
- Em código de serialização chamado frequentemente → usar codegen ou cache agressivo
- Para acesso simples a propriedades onde o tipo é conhecido → acesso direto é 50–100x mais rápido

## Quando RTTI é a ferramenta certa

- **Mappers ORM** — uma vez por requisição/transação
- **Serialização JSON** — uma vez por objeto, cache de TRttiType
- **Validadores** — chamado raramente, coerência > performance
- **DI containers** — startup only
- **Auto-bind de forms** — OnCreate/OnLoad — não em OnPaint/OnTimer

## Diretiva de controle de RTTI

```pascal
// Padrão Delphi: public + published têm RTTI
// Para forçar RTTI em campos private (útil para mappers):
{$RTTI EXPLICIT FIELDS([vcPrivate, vcPublic, vcPublished])
                METHODS([vcPublic, vcPublished])
                PROPERTIES([vcPublic, vcPublished])}
type
  TMinhaClasse = class
  private
    FNome: string;  // agora visível via TRttiField
  end;

// Para desativar RTTI e economizar espaço (ex.: classes utilitárias):
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
```
