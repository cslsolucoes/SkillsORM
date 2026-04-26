# LiveBindings FMX — Resumo rápido

## Componentes principais

| Componente | Unit | Papel |
|------------|------|-------|
| `TBindingsList` | `Data.Bind.Components` | Container de todos os bindings do form |
| `TLinkControlToField` | `Fmx.Bind.Editors` | Bidirecional: controle ↔ campo do dataset |
| `TLinkPropertyToField` | `Data.Bind.Components` | Unidirecional: propriedade ← campo |
| `TBindSourceDB` | `Data.Bind.DBScope` | Ponte entre TDataSource e bindings |
| `TDataSource` | `Data.DB` | Conector entre TDataSet e consumidores |

---

## Hierarquia típica

```
TDataSet (TFDQuery / TQuery / TClientDataSet)
└── TDataSource
    └── TBindSourceDB (BindSourceDB1)
        ├── TLinkControlToField → Edit1.Text ↔ NOME
        ├── TLinkControlToField → Edit2.Text ↔ EMAIL
        └── TLinkPropertyToField → Label1.Text ← NOME (leitura)
```

---

## TLinkControlToField — bidirecional

```pascal
// Runtime:
var B := TLinkControlToField.Create(Self);
B.Control    := Edit1;          // controle FMX
B.DataSource := BindSourceDB1;  // fonte de dados
B.FieldName  := 'NOME';         // nome do campo no dataset
B.Active     := True;

// Design-time (mais comum):
// usar LiveBindings Designer e arrastar conexão
```

Funciona com: `TEdit`, `TMemo`, `TComboBox`, `TCheckBox`, `TDateEdit`, `TSpinBox`, `TTrackBar`.

---

## TLinkPropertyToField — unidirecional

```pascal
// Runtime:
var B := TLinkPropertyToField.Create(Self);
B.Component         := Label1;        // qualquer TComponent
B.ComponentProperty := 'Text';        // nome da propriedade
B.DataSource        := BindSourceDB1;
B.FieldName         := 'NOME';
B.Active            := True;
```

Útil para exibir dados em componentes que TLinkControlToField não suporta.

---

## TBindingsList — ativar/desativar todos

```pascal
// Ativar (sincronizar dataset → controles)
BindingsList1.Active := True;

// Desativar (controles param de atualizar)
BindingsList1.Active := False;

// Notificar mudança manual de dataset
BindingsList1.Notify(BindSourceDB1, '');
```

---

## Configuração do TBindSourceDB

```pascal
// Design-time:
BindSourceDB1.DataSource := DataSource1;

// O DataSource aponta para o DataSet:
DataSource1.DataSet := FDQuery1;
```

---

## Fluxo de atualização

```
Usuário edita Edit1
  → TLinkControlToField detecta mudança
    → Atualiza campo NOME no dataset (POST automático ou manual)

Dataset recebe novo registro (FDQuery1.Next)
  → TBindSourceDB notifica
    → TLinkControlToField atualiza Edit1.Text
    → TLinkPropertyToField atualiza Label1.Text
```

---

## Limitações e alternativas

| Situação | Solução |
|----------|---------|
| Componente customizado (não suportado) | TLinkPropertyToField com nome da propriedade |
| Performance em listas grandes | TListView com população manual (mais rápido) |
| Binding complexo (cálculo) | TExpression no LiveBindings Designer |
| Sem TDataSet (objeto PODO) | TObjectBindSource em vez de TBindSourceDB |

---

## Units necessárias

```pascal
uses
  Data.Bind.Components,    // TBindingsList, TLinkPropertyToField
  Data.Bind.ObjectScope,   // TObjectBindSource
  Data.Bind.EngExt,        // extensões de engine
  Fmx.Bind.Editors,        // TLinkControlToField para FMX
  Data.Bind.DBScope,       // TBindSourceDB
  Data.DB;                 // TDataSource
```
