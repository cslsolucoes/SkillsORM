unit livebindings_basico;
// LiveBindings FMX: TBindingsList, TLinkControlToField, TLinkPropertyToField

interface

uses
  FMX.Forms, FMX.Controls, FMX.Edit,
  Data.Bind.Components, Data.Bind.ObjectScope, Data.Bind.EngExt,
  Fmx.Bind.Editors, Data.Bind.DBScope, Data.DB;

// Criar binding bidirecional TEdit <-> TField
function CriarBindingEditParaField(AOwner: TComponent;
  AEdit: TEdit;
  ADataSource: TBindSourceDB;
  const AFieldName: string): TLinkControlToField;

// Criar binding de propriedade unidirecional (Label <- Field)
function CriarBindingPropriedade(AOwner: TComponent;
  AComponent: TComponent;
  const AComponentProperty: string;
  ADataSource: TBindSourceDB;
  const AFieldName: string): TLinkPropertyToField;

// Ativar / desativar todos os bindings de uma lista
procedure AtivarBindings(ABindingsList: TBindingsList; AAtivo: Boolean = True);

implementation

function CriarBindingEditParaField(AOwner: TComponent;
  AEdit: TEdit;
  ADataSource: TBindSourceDB;
  const AFieldName: string): TLinkControlToField;
begin
  Result := TLinkControlToField.Create(AOwner);
  Result.Control    := AEdit;
  Result.DataSource := ADataSource;
  Result.FieldName  := AFieldName;
  Result.Active     := True;
end;

function CriarBindingPropriedade(AOwner: TComponent;
  AComponent: TComponent;
  const AComponentProperty: string;
  ADataSource: TBindSourceDB;
  const AFieldName: string): TLinkPropertyToField;
begin
  Result := TLinkPropertyToField.Create(AOwner);
  Result.Component         := AComponent;
  Result.ComponentProperty := AComponentProperty;
  Result.DataSource        := ADataSource;
  Result.FieldName         := AFieldName;
  Result.Active            := True;
end;

procedure AtivarBindings(ABindingsList: TBindingsList; AAtivo: Boolean);
begin
  ABindingsList.Active := AAtivo;
end;

// ============================================================
// EXEMPLO DE USO:
//
// No FormCreate, criando bindings em runtime:
//   CriarBindingEditParaField(Self, edtNome,   BindSourceDB1, 'NOME');
//   CriarBindingEditParaField(Self, edtEmail,  BindSourceDB1, 'EMAIL');
//   CriarBindingEditParaField(Self, edtTelefone, BindSourceDB1, 'TELEFONE');
//
//   // Label que mostra o nome (unidirecional: dataset -> label)
//   CriarBindingPropriedade(Self, lblNomeDisplay, 'Text',
//     BindSourceDB1, 'NOME');
//
// CONFIGURAÇÃO DO TBindSourceDB:
//   BindSourceDB1.DataSource := DataSource1; // aponta para o TDataSet
//
// CONFIGURAÇÃO DO TDataSource:
//   DataSource1.DataSet := Query1; // aponta para a query/tabela
//
// HIERARQUIA DE BINDINGS:
//   TDataSet (TQuery/TTable)
//   └── TDataSource
//       └── TBindSourceDB
//           ├── TLinkControlToField (bidirecional: Edit ↔ Field)
//           └── TLinkPropertyToField (unidirecional: Label <- Field)
//
// DESIGN-TIME (mais comum que runtime):
//   1. Soltar TBindingsList no form
//   2. Abrir LiveBindings Designer (View → LiveBindings Designer)
//   3. Arrastar conexão: Edit.Text → Field.NOME
//   Isso cria automaticamente TLinkControlToField no BindingsList
//
// ATENÇÃO:
//   - TLinkControlToField funciona com TEdit, TComboBox, TCheckBox, etc.
//   - Para componentes customizados, usar TLinkPropertyToField
//   - Active := True em BindingsList ativa todos os bindings de uma vez
// ============================================================

end.
