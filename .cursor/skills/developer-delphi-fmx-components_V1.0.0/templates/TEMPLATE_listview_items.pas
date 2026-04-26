unit TEMPLATE_listview_items;
// TEMPLATE: TListView com itens customizados (imagem + texto + badge)
// Padrão GestorERP: lista de registros com indicadores de status

interface

uses
  FMX.Forms, FMX.Controls, FMX.ListView, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.Types, System.UITypes, System.Classes,
  System.SysUtils;

type
  TStatusItem = (siNenhum, siPendente, siAtivo, siInativo, siAlerta);

  TRegistroLista = record
    ID      : Integer;
    Titulo  : string;
    Subtitulo: string;
    Status  : TStatusItem;
  end;

// Inicializar TListView com aparência padrão do GestorERP
procedure InicializarListaRegistros(AListView: TListView);

// Popular lista com dados
procedure PopularListaRegistros(AListView: TListView;
  const ARegistros: array of TRegistroLista);

// Cor de badge por status
function CorStatus(AStatus: TStatusItem): TAlphaColor;

// Texto de badge por status
function TextoStatus(AStatus: TStatusItem): string;

implementation

procedure InicializarListaRegistros(AListView: TListView);
begin
  AListView.ItemAppearance.ItemAppearance := 'ImageListItemRightButton';
  AListView.ItemAppearanceObjects.ItemObjects.Height := 64;
  AListView.ShowSelection := True;
  AListView.Cursor        := crHandPoint;
  AListView.AniCalculations.Animation := True;

  // Sem separador visual (estilo moderno)
  AListView.Transparent := True;
end;

procedure PopularListaRegistros(AListView: TListView;
  const ARegistros: array of TRegistroLista);
var
  I   : Integer;
  Item: TListViewItem;
begin
  AListView.BeginUpdate;
  try
    AListView.Items.Clear;

    for I := 0 to High(ARegistros) do
    begin
      Item := AListView.Items.Add;
      Item.Text    := ARegistros[I].Titulo;
      Item.Detail  := ARegistros[I].Subtitulo;
      Item.Tag     := ARegistros[I].ID;

      // Texto do botão direito (badge de status)
      var BtnObj := Item.Objects.FindObjectT<TListItemSimpleControl>('button');
      if Assigned(BtnObj) then
      begin
        BtnObj.Text := TextoStatus(ARegistros[I].Status);
      end;
    end;
  finally
    AListView.EndUpdate;
  end;
end;

function CorStatus(AStatus: TStatusItem): TAlphaColor;
begin
  case AStatus of
    siPendente : Result := $FFF39C12; // laranja
    siAtivo    : Result := $FF27AE60; // verde
    siInativo  : Result := $FF95A5A6; // cinza
    siAlerta   : Result := $FFE74C3C; // vermelho
  else
    Result := $FF3498DB; // azul padrão
  end;
end;

function TextoStatus(AStatus: TStatusItem): string;
begin
  case AStatus of
    siPendente : Result := 'Pendente';
    siAtivo    : Result := 'Ativo';
    siInativo  : Result := 'Inativo';
    siAlerta   : Result := 'Alerta';
  else
    Result := '';
  end;
end;

// ============================================================
// USO:
//
// procedure TFormListagem.FormCreate(Sender: TObject);
// begin
//   InicializarListaRegistros(ListView1);
// end;
//
// procedure TFormListagem.CarregarDados;
// var Regs: array of TRegistroLista;
// begin
//   SetLength(Regs, 3);
//
//   Regs[0].ID        := 1001;
//   Regs[0].Titulo    := 'Pedido #1001';
//   Regs[0].Subtitulo := 'Cliente: ACME Corp · R$ 3.500,00';
//   Regs[0].Status    := siPendente;
//
//   Regs[1].ID        := 1002;
//   Regs[1].Titulo    := 'Pedido #1002';
//   Regs[1].Subtitulo := 'Cliente: XYZ Ltda · R$ 1.200,00';
//   Regs[1].Status    := siAtivo;
//
//   PopularListaRegistros(ListView1, Regs);
// end;
//
// procedure TFormListagem.ListView1ItemClick(
//   const Sender: TObject; const AItem: TListViewItem);
// begin
//   // AItem.Tag = ID do registro
//   AbrirDetalhe(AItem.Tag);
// end;
//
// BUSCA/FILTRO:
//   ListView1.SearchEnabled := True; // ativa caixa de busca nativa
//   ListView1.OnSearchChange := ProcFiltro; // callback ao digitar
//
// SWIPE-TO-DELETE:
//   ListView1.CanSwipeDelete := True;
//   ListView1.OnDeleteItem   := ProcAntesExcluir;
// ============================================================

end.
