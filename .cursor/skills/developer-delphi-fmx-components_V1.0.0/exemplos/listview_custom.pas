unit listview_custom;
// TListView com ItemAppearance customizado — padrão FMX

interface

uses
  FMX.Forms, FMX.Controls, FMX.ListView, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.Types, System.UITypes, System.Classes;

type
  // Dados para um item de lista
  TDadosItem = record
    Titulo  : string;
    Detalhe : string;
    Badge   : string;   // texto do badge (ex: '3', 'Novo')
    Ativo   : Boolean;
  end;

// Configurar ListView com aparência padrão (título + detalhe)
procedure ConfigurarListView(AListView: TListView);

// Popular ListView com array de dados
procedure PopularListView(AListView: TListView;
  const ADados: array of TDadosItem);

// Obter texto do item selecionado
function ItemSelecionado(AListView: TListView): string;

// Limpar e repopular (evita flicker)
procedure RefrescarListView(AListView: TListView;
  const ADados: array of TDadosItem);

implementation

procedure ConfigurarListView(AListView: TListView);
begin
  // Aparência: imagem à esquerda + título + detalhe à direita
  AListView.ItemAppearance.ItemAppearance := 'ImageListItem';

  // Altura dos itens
  AListView.ItemAppearanceObjects.ItemObjects.Height := 60;

  // Sem marcação de seleção em iOS-style
  AListView.ShowSelection := True;

  // Scroll suave
  AListView.AniCalculations.Animation := True;
end;

procedure PopularListView(AListView: TListView;
  const ADados: array of TDadosItem);
var
  I   : Integer;
  Item: TListViewItem;
begin
  AListView.BeginUpdate;
  try
    for I := 0 to High(ADados) do
    begin
      Item := AListView.Items.Add;
      Item.Text   := ADados[I].Titulo;
      Item.Detail := ADados[I].Detalhe;

      // Tag para identificação (índice do array original)
      Item.Tag := I;

      // Objeto de texto para badge (se usar aparência com objetos)
      if ADados[I].Badge <> '' then
      begin
        var BadgeObj := Item.Objects.FindObjectT<TListItemText>('badge');
        if Assigned(BadgeObj) then
          BadgeObj.Text := ADados[I].Badge;
      end;
    end;
  finally
    AListView.EndUpdate;
  end;
end;

function ItemSelecionado(AListView: TListView): string;
begin
  Result := '';
  if AListView.ItemIndex >= 0 then
    Result := AListView.Items[AListView.ItemIndex].Text;
end;

procedure RefrescarListView(AListView: TListView;
  const ADados: array of TDadosItem);
begin
  AListView.BeginUpdate;
  try
    AListView.Items.Clear;
    PopularListView(AListView, ADados);
  finally
    AListView.EndUpdate;
  end;
end;

// ============================================================
// APARÊNCIAS DISPONÍVEIS:
//   'ListItem'                  — título simples
//   'ListItemRightDetail'       — título + detalhe à direita
//   'ImageListItem'             — imagem + título + detalhe
//   'ImageListItemRightButton'  — imagem + título + botão direita
//   'Custom'                    — aparência totalmente customizada
//
// ACESSO A OBJETOS DE ITEM (aparência Custom):
//   var TxtObj := Item.Objects.FindObjectT<TListItemText>('title');
//   var ImgObj := Item.Objects.FindObjectT<TListItemImage>('icon');
//   var BtnObj := Item.Objects.FindObjectT<TListItemSimpleControl>('btn');
//
// EVENTOS:
//   OnItemClick: disparado ao clicar em item
//     procedure(const Sender: TObject; const AItem: TListViewItem)
//
//   OnItemChange: disparado quando ItemIndex muda
//
//   OnDeleteItem: disparado antes de excluir item (swipe-to-delete)
//
// EXEMPLO DE USO:
//   procedure TFormPrincipal.FormCreate(Sender: TObject);
//   begin
//     ConfigurarListView(ListView1);
//
//     var Dados: array[0..2] of TDadosItem;
//     Dados[0].Titulo  := 'Pedido #1001';
//     Dados[0].Detalhe := 'R$ 1.250,00 · Pendente';
//     Dados[0].Badge   := '2';
//     Dados[0].Ativo   := True;
//     // ... preencher mais...
//     PopularListView(ListView1, Dados);
//   end;
//
//   procedure TFormPrincipal.ListView1ItemClick(const Sender: TObject;
//     const AItem: TListViewItem);
//   begin
//     ShowMessage('Clicou: ' + AItem.Text);
//   end;
//
// PERFORMANCE:
//   - Usar BeginUpdate/EndUpdate para lotes de alterações
//   - Não chamar Items.Clear sem BeginUpdate (causa flicker)
//   - Para listas grandes (1000+): considerar virtual mode
// ============================================================

end.
