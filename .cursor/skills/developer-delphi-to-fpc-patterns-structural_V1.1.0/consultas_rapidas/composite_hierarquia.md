# Composite — Component / Leaf / Composite

## Estrutura canônica

```
IComponent         ← interface com operações uniformes
  TLeaf            ← implementa IComponent, sem filhos
  TComposite       ← implementa IComponent, tem TList<IComponent>
```

## Três participantes

### Component (interface)
Define operações que funcionam para folhas E compostos.

```pascal
type IUIComponent = interface
  procedure Render(AIndent: Integer);
  function  Calcular: Integer;
  procedure SetVisible(AVal: Boolean);
end;
```

### Leaf (folha)
Implementa operações diretamente — sem filhos.

```pascal
type TUILabel = class(TInterfacedObject, IUIComponent)
  procedure Render(AIndent: Integer);
  function  Calcular: Integer; // retorna próprio peso
  procedure SetVisible(AVal: Boolean);
end;
```

### Composite (galho)
Implementa operações **recursivamente** sobre filhos.

```pascal
type TUIPanel = class(TInterfacedObject, IUIComponent)
private
  FFilhos: TList<IUIComponent>;
public
  procedure Add(AComp: IUIComponent);
  procedure Remove(AComp: IUIComponent);

  procedure Render(AIndent: Integer);
  function  Calcular: Integer;      // soma filhos recursivamente
  procedure SetVisible(AVal: Boolean);  // propaga para filhos
end;
```

---

## Operações recursivas — padrão

```pascal
// SetVisible propaga para toda a sub-árvore
procedure TUIPanel.SetVisible(AVal: Boolean);
var C: IUIComponent;
begin
  FVisible := AVal;
  for C in FFilhos do
    C.Visible := AVal;  // cada filho repete recursão se também for Composite
end;

// Calcular acumula da raiz às folhas
function TUIPanel.Calcular: Integer;
var C: IUIComponent;
begin
  Result := 0;
  for C in FFilhos do
    Inc(Result, C.Calcular);  // folha retorna próprio valor; composto soma filhos
end;
```

---

## Gerência de filhos — onde colocar?

| Opção | Prós | Contras |
|-------|------|---------|
| Add/Remove na interface Component | Cliente trata tudo como IComponent | Quebra LSP — Leaf.Add é inválido |
| Add/Remove só no Composite | Seguro — Leaf não tem Add | Cliente precisa de cast para TUIPanel |
| Add/Remove na interface com exceção em Leaf | Compromisso | Lança em runtime se errar |

**Recomendação Delphi:** Add/Remove apenas na classe concreta `TUIPanel`; usar `Find` para navegar a árvore.

---

## Visitor sobre a árvore

```pascal
type TUIVisitor = reference to procedure(C: IUIComponent; Level: Integer);

procedure PercorrerArvore(Root: IUIComponent; Visit: TUIVisitor; Level: Integer = 0);
var C: IUIComponent;
begin
  Visit(Root, Level);
  if Root is TUIPanel then
    for C in TUIPanel(Root).Filhos do
      PercorrerArvore(C, Visit, Level + 1);
end;

// Uso
PercorrerArvore(Form,
  procedure(C: IUIComponent; L: Integer)
  begin Writeln(StringOfChar(' ', L*2), C.Nome); end);
```

---

## Casos de uso clássicos

| Domínio | Component | Leaf | Composite |
|---------|-----------|------|-----------|
| UI | IWidget | TButton, TLabel | TPanel, TForm |
| Sistema de arquivos | IFSEntry | TArquivo | TDiretorio |
| Expressões | IExpressao | TNumero, TVariavel | TBinOp, TFuncCall |
| Menu | IMenuItem | TMenuItem | TSubMenu |
| Organização | IOrg | TFuncionario | TDepartamento |
