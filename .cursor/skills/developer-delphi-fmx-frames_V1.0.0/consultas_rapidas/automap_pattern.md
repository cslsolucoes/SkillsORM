# Padrão Automap edt*↔txt* — FindComponent no GestorERP

## O que é

Convenção do GestorERP onde campos de edição têm prefixo `edt` e seus labels
correspondentes têm prefixo `txt` com o mesmo sufixo. Um procedimento genérico
percorre os componentes e faz o mapeamento automático.

## Convenção de nomes

```
edtNome      ↔  txtNome      (TEdit ↔ TLabel)
edtEmail     ↔  txtEmail
edtCep       ↔  txtCep
edtTelefone  ↔  txtTelefone
```

## Implementação

```pascal
// Mapear todos os TEdit edt* para seus TLabel txt* correspondentes
procedure AutoMapearCampos(AContainer: TFmxObject;
  AMapCallback: TProc<TEdit, TLabel>);
var
  I: Integer;
  Comp: TFmxObject;
  Edit: TEdit;
  LabelNome: string;
  Lbl: TLabel;
begin
  for I := 0 to AContainer.ChildrenCount - 1 do
  begin
    Comp := AContainer.Children[I];

    if (Comp is TEdit) and (Comp.Name.StartsWith('edt')) then
    begin
      Edit      := TEdit(Comp);
      LabelNome := 'txt' + Copy(Edit.Name, 4, MaxInt); // troca prefixo

      // Buscar o label pelo nome no mesmo container
      Lbl := AContainer.FindComponent(LabelNome) as TLabel;

      if Assigned(Lbl) and Assigned(AMapCallback) then
        AMapCallback(Edit, Lbl);
    end;

    // Recursivo para containers filhos
    if Comp.ChildrenCount > 0 then
      AutoMapearCampos(Comp, AMapCallback);
  end;
end;
```

## Uso: preencher labels com valores dos edits

```pascal
// Modo leitura: copiar texto dos TEdit para os TLabel
procedure ModoLeitura(AFrame: TFrame);
begin
  AutoMapearCampos(AFrame,
    procedure(AEdit: TEdit; ALabel: TLabel)
    begin
      ALabel.Text := AEdit.Text;
      AEdit.Visible := False;
      ALabel.Visible := True;
    end);
end;
```

## Uso: limpar todos os campos

```pascal
procedure LimparCampos(AFrame: TFrame);
begin
  AutoMapearCampos(AFrame,
    procedure(AEdit: TEdit; ALabel: TLabel)
    begin
      AEdit.Text := '';
    end);
end;
```

## Validação automática de campos obrigatórios

```pascal
// Campos marcados com Tag = 1 sao obrigatorios
function ValidarObrigatorios(AFrame: TFrame): string;
begin
  Result := '';
  AutoMapearCampos(AFrame,
    procedure(AEdit: TEdit; ALabel: TLabel)
    begin
      if (AEdit.Tag = 1) and AEdit.Text.Trim.IsEmpty then
        Result := Result + ALabel.Text + ' e obrigatorio.' + sLineBreak;
    end);
end;
```

## Alternativa: usar FindComponent diretamente

```pascal
// Quando sabe o nome do campo especifico
var Edit := Frame.FindComponent('edtNome') as TEdit;
if Assigned(Edit) then
  Edit.Text := 'Joao Silva';
```

## Dicas

- Manter a convenção `edt*`/`txt*` rigorosamente — o automap falha se o nome difere
- Para containers aninhados, passar o TScrollBox ou TLayout como raiz
- `FindComponent` busca apenas filhos diretos — para recursivo, use `Children[]`
