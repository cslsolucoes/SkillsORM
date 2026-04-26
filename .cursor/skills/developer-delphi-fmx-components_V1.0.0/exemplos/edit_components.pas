unit edit_components;
// TEdit, TMemo, TComboBox, TDateEdit — propriedades e padrões FMX

interface

uses
  FMX.Forms, FMX.Controls, FMX.Edit, FMX.Memo, FMX.DateTimeCtrls,
  FMX.ListBox, FMX.Types, System.UITypes, System.Classes;

// Configurar TEdit para campo de senha
procedure ConfigurarEditSenha(AEdit: TEdit);

// Configurar TEdit com validação de foco (borda destaque no focus)
procedure ConfigurarEditComFoco(AEdit: TEdit;
  ACorFoco: TAlphaColor = $FF3498DB);

// Preencher TComboBox com lista de strings
procedure PreencherComboBox(AComboBox: TComboBox;
  const AItens: array of string;
  AIndexPadrao: Integer = 0);

// Ler data segura de TDateEdit (retorna Now se vazio)
function LerData(ADateEdit: TDateEdit): TDate;

implementation

uses
  FMX.Ani, FMX.Objects;

procedure ConfigurarEditSenha(AEdit: TEdit);
begin
  AEdit.Password   := True;
  AEdit.MaxLength  := 128;
  AEdit.TextPrompt := 'Senha';
  AEdit.ReturnKeyType := TReturnKeyType.Done;
end;

procedure ConfigurarEditComFoco(AEdit: TEdit; ACorFoco: TAlphaColor);
begin
  // OnEnter: destacar borda
  AEdit.OnEnter := procedure(Sender: TObject)
  begin
    TAnimator.AnimateColor(AEdit, 'TextSettings.FontColor',
      ACorFoco, 0.15);
  end;

  // OnExit: restaurar cor original
  AEdit.OnExit := procedure(Sender: TObject)
  begin
    TAnimator.AnimateColor(AEdit, 'TextSettings.FontColor',
      $FF333333, 0.15);
  end;
end;

procedure PreencherComboBox(AComboBox: TComboBox;
  const AItens: array of string; AIndexPadrao: Integer);
var
  I: Integer;
begin
  AComboBox.BeginUpdate;
  try
    AComboBox.Items.Clear;
    for I := 0 to High(AItens) do
      AComboBox.Items.Add(AItens[I]);

    if (AIndexPadrao >= 0) and (AIndexPadrao < AComboBox.Items.Count) then
      AComboBox.ItemIndex := AIndexPadrao;
  finally
    AComboBox.EndUpdate;
  end;
end;

function LerData(ADateEdit: TDateEdit): TDate;
begin
  if ADateEdit.IsEmpty then
    Result := Now
  else
    Result := ADateEdit.Date;
end;

// ============================================================
// PROPRIEDADES CHAVE DE TEdit:
//   .Text          — valor atual
//   .TextPrompt    — placeholder (aparece quando vazio)
//   .Password      — mascara com *
//   .MaxLength     — limite de caracteres (0=sem limite)
//   .ReadOnly      — somente leitura
//   .Enabled       — habilitar/desabilitar
//   .OnChange      — disparado a cada tecla
//   .OnValidate    — disparado ao perder foco, com validação
//   .ReturnKeyType — tipo da tecla Enter: Default, Done, Next, Search
//   .KeyboardType  — tipo do teclado: Default, NumberPad, EmailAddress, etc.
//
// PROPRIEDADES CHAVE DE TMemo:
//   .Lines.Text    — texto completo com quebras
//   .Lines.Add()   — adicionar linha
//   .Lines.Count   — número de linhas
//   .ReadOnly      — somente leitura
//   .ScrollBy(X,Y) — rolar conteúdo
//   .ContentBounds — retângulo do conteúdo (útil para scroll total)
//   .LineCount     — número de linhas visíveis
//
// PROPRIEDADES CHAVE DE TComboBox:
//   .Items         — TStrings com os itens
//   .ItemIndex     — índice selecionado (-1 = nenhum)
//   .Items[I]      — texto do item I
//   .Count         — número de itens
//   .DropDownCount — quantos itens mostrar no dropdown
//   .OnChange      — disparado quando seleção muda
//
// PROPRIEDADES CHAVE DE TDateEdit:
//   .Date          — TDate selecionada
//   .Format        — formato de exibição: 'dd/mm/yyyy'
//   .IsEmpty       — True se nenhuma data foi selecionada
//   .MinDate       — data mínima permitida
//   .MaxDate       — data máxima permitida
//   .OnChange      — disparado quando data muda
//
// PADRÃO DE LEITURA SEGURA:
//   // Evitar ler texto de Edit desconectado
//   if Assigned(edtNome) and (edtNome.Text <> '') then
//     Nome := edtNome.Text;
//
//   // Ler inteiro com segurança
//   Valor := StrToIntDef(edtValor.Text, 0);
//
//   // Ler float com segurança
//   Valor := StrToFloatDef(edtPreco.Text, 0);
// ============================================================

end.
