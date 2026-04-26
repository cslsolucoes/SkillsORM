unit TEMPLATE_form_binding;
// TEMPLATE: Form com LiveBindings — TEdit sincronizado com TDataSet
// Padrão CRUD: form de edição com campos bindings automáticos

interface

uses
  FMX.Forms, FMX.Controls, FMX.Edit, FMX.Memo, FMX.DateTimeCtrls,
  Data.Bind.Components, Data.Bind.ObjectScope, Data.Bind.EngExt,
  Fmx.Bind.Editors, Data.Bind.DBScope, Data.DB,
  FMX.DialogService, FMX.Types, System.UITypes, System.SysUtils;

// Configuração de binding para um campo Edit+Field
type
  TBindingConfig = record
    Edit     : TControl;   // TEdit, TComboBox, TCheckBox etc.
    FieldName: string;     // nome do campo no dataset
  end;

// Inicializar todos os bindings de um form de edição
// AOwner        = TForm (Self)
// ABindingsList = TBindingsList do form
// ABindSource   = TBindSourceDB do form
// AConfigs      = array com cada Edit → FieldName
procedure InicializarBindings(
  AOwner       : TComponent;
  ABindingsList: TBindingsList;
  ABindSource  : TBindSourceDB;
  const AConfigs: array of TBindingConfig);

// Salvar registro: Post no dataset + tratar erros
procedure SalvarRegistro(
  ADataSource: TDataSource;
  AOnSucesso: TProc;
  AOnErro: TProc<string>);

// Cancelar edição: Cancel no dataset
procedure CancelarEdicao(ADataSource: TDataSource);

// Novo registro: Insert no dataset
procedure NovoRegistro(ADataSource: TDataSource);

implementation

procedure InicializarBindings(
  AOwner       : TComponent;
  ABindingsList: TBindingsList;
  ABindSource  : TBindSourceDB;
  const AConfigs: array of TBindingConfig);
var
  I: Integer;
  B: TLinkControlToField;
begin
  for I := 0 to High(AConfigs) do
  begin
    B := TLinkControlToField.Create(AOwner);
    B.Control    := AConfigs[I].Edit;
    B.DataSource := ABindSource;
    B.FieldName  := AConfigs[I].FieldName;
    B.Active     := True;
  end;

  ABindingsList.Active := True;
end;

procedure SalvarRegistro(ADataSource: TDataSource;
  AOnSucesso: TProc; AOnErro: TProc<string>);
begin
  try
    if ADataSource.DataSet.State in [dsInsert, dsEdit] then
    begin
      ADataSource.DataSet.Post;
      if Assigned(AOnSucesso) then AOnSucesso();
    end;
  except
    on E: Exception do
    begin
      ADataSource.DataSet.Cancel;
      if Assigned(AOnErro) then
        AOnErro(E.Message)
      else
        TDialogService.ShowMessage('Erro ao salvar: ' + E.Message);
    end;
  end;
end;

procedure CancelarEdicao(ADataSource: TDataSource);
begin
  if ADataSource.DataSet.State in [dsInsert, dsEdit] then
    ADataSource.DataSet.Cancel;
end;

procedure NovoRegistro(ADataSource: TDataSource);
begin
  ADataSource.DataSet.Insert;
end;

// ============================================================
// USO NO FORM DE EDIÇÃO:
//
// procedure TFormCadastroCliente.FormCreate(Sender: TObject);
// var Configs: array[0..3] of TBindingConfig;
// begin
//   // Configurar bindings Edit → Field
//   Configs[0].Edit      := edtNome;     Configs[0].FieldName := 'NOME';
//   Configs[1].Edit      := edtEmail;    Configs[1].FieldName := 'EMAIL';
//   Configs[2].Edit      := edtTelefone; Configs[2].FieldName := 'TELEFONE';
//   Configs[3].Edit      := dtNascimento; Configs[3].FieldName := 'DT_NASCIMENTO';
//
//   InicializarBindings(Self, BindingsList1, BindSourceDB1, Configs);
// end;
//
// procedure TFormCadastroCliente.BtnSalvarClick(Sender: TObject);
// begin
//   SalvarRegistro(DataSource1,
//     procedure begin
//       TDialogService.ShowMessage('Cliente salvo com sucesso!');
//       ModalResult := mrOk;
//     end,
//     procedure(const Msg: string)
//     begin
//       TDialogService.ShowMessage('Erro: ' + Msg);
//     end);
// end;
//
// procedure TFormCadastroCliente.BtnCancelarClick(Sender: TObject);
// begin
//   CancelarEdicao(DataSource1);
//   ModalResult := mrCancel;
// end;
//
// ABRIR PARA NOVO REGISTRO:
//   NovoRegistro(DataSource1);
//   FormCadastroCliente.ShowModal;
//
// ABRIR PARA EDITAR REGISTRO EXISTENTE:
//   FDQuery1.Locate('ID', AID, []);  // posicionar no registro
//   FDQuery1.Edit;                    // entrar em modo edição
//   FormCadastroCliente.ShowModal;
//
// REQUISITO NO FORM:
//   - TBindingsList (BindingsList1)
//   - TBindSourceDB (BindSourceDB1) conectado ao TDataSource
//   - TDataSource (DataSource1) conectado ao TDataSet (TFDQuery1)
// ============================================================

end.
