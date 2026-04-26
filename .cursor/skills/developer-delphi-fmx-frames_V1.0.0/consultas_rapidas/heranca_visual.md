# Herança Visual em FMX — TFrame

## Como funciona

Em FMX, herança visual significa que uma classe filha herda o **arquivo .fmx**
(o layout) da classe base. A diretiva `inherited` no arquivo `.fmx` filho
preserva todos os componentes da base e permite adicionar novos.

## Estrutura de arquivos

```
TFrameBase         → FrameBase.pas + FrameBase.fmx
  └─ TFrameCRUD    → FrameCRUD.pas + FrameCRUD.fmx (contém `inherited`)
       └─ TFrameClientesCRUD → FrameClientesCRUD.pas + FrameClientesCRUD.fmx
```

## Arquivo .fmx filho (conteúdo obrigatório)

```
inherited FrameCRUD: TFrameCRUD
  // componentes adicionados aqui aparecem ALÉM dos da base
  object BtnEspecifico: TButton
    Text = 'Acao especifica'
  end
end
```

## No .pas filho

```pascal
type
  TFrameCRUD = class(TFrameBase)
  protected
    // Override de metodos virtuais
    procedure DoSalvar; override;
    procedure DoCarregar; override;
  end;
```

## Regras de herança FMX

| Regra | Detalhe |
|-------|---------|
| Componentes da base são herdados automaticamente | Não precisam ser redeclarados |
| Eventos da base podem ser sobrescritos | Usar `override` no método |
| Propriedades visuais da base podem ser alteradas no filho | Ex.: mudar cor de um TRectangle herdado |
| `inherited` no constructor chama o constructor da base | Sempre chamar `inherited` primeiro |

## Acesso a componentes da base no filho

```pascal
// Se TFrameBase tem RecFundo: TRectangle;
// TFrameCRUD pode acessar diretamente:
procedure TFrameCRUD.AjustarCores;
begin
  RecFundo.Fill.Color := $FF2C3E50; // acesso direto ao componente herdado
end;
```

## Armadilhas comuns

```pascal
// ERRADO: criar componente da base no constructor do filho sem inherited
constructor TFrameCRUD.Create(AOwner: TComponent);
begin
  // inherited Create(AOwner);  ← FALTOU! RecFundo nao existe ainda
  RecFundo.Fill.Color := $FF0000; // AV: RecFundo = nil
end;

// CORRETO:
constructor TFrameCRUD.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); // cria RecFundo e todos os componentes da base
  RecFundo.Fill.Color := $FF0000; // seguro
end;
```

## Quando usar herança vs composição

| Situação | Recomendação |
|----------|-------------|
| Múltiplos CRUDs com mesmo layout base | Herança: TFrameBase → TFrameClientesCRUD |
| Widgets independentes e reutilizáveis | Composição: TFrameCartao dentro de TFrameLista |
| Polimorfismo necessário (form pai não sabe o tipo) | Herança + interface/abstrato |
| Frames completamente diferentes | Composição (evita acoplar layouts) |
