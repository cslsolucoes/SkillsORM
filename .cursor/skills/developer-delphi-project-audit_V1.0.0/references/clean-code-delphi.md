# Clean Code em Delphi
## Baseado em "Código Limpo" — Robert C. Martin

---

## 1. Nomes Significativos

### 1.1 Regra Geral
Nomes devem revelar intenção. Se um nome precisa de comentário para ser entendido, está errado.

```pascal
// RUIM
var d: Integer; // dias desde criação

// BOM
var LDiasDesdeAbertura: Integer;
```

### 1.2 Prefixos por Escopo

| Escopo | Prefixo | Exemplo |
|---|---|---|
| Variável local | `L` | `LValorICMS`, `LQryAux` |
| Field/atributo | `F` | `FValorTotal`, `FCodCliente` |
| Parâmetro | `A` | `AAliquota`, `AValor`, `ANome` |
| Constante | `C_` | `C_SQL_PEDIDOS`, `C_MAX_TENTATIVAS` |
| Componente botão | `btn` | `btnSalvar`, `btnCancelar` |
| Componente edit | `edt` | `edtNome`, `edtCPF` |
| Componente label | `lbl` | `lblTotal`, `lblStatus` |
| Componente combo | `cbx` | `cbxEstado`, `cbxStatus` |
| Componente grid | `grd` | `grdPedidos`, `grdItens` |
| Query | `qry` | `qryClientes`, `qryPedidos` |

> NUNCA usar `p` como prefixo de parâmetro (confunde com ponteiro). O padrão Delphi usa `A`.

### 1.3 Exemplos de Renomeação

```pascal
// RUIM — abreviações, siglas obscuras, sem prefixo
procedure CICMS(pAliq: Double; pVal: Double);
var i, v, s: Integer;
procedure ConfirmaTrans;
procedure LancarServMaster;

// BOM — intenção clara, padrão aplicado
procedure CalcularICMS(const AAliquota: Double; const AValor: Double);
var LIndice, LValor, LStatus: Integer;
procedure ConfirmarTransacao;
procedure LancarServidorMaster;
```

### 1.4 Componentes
Todo componente referenciado via código deve ser renomeado:

```pascal
// RUIM — nome default do Delphi
Edit1.Text := 'Adriano';
Label1.Caption := 'Nome:';
Button1.Enabled := False;

// BOM — nome significativo com prefixo
edtNome.Text := 'Adriano';
lblNome.Caption := 'Nome:';
btnSalvar.Enabled := False;
```

---

## 2. Funções e Métodos

### 2.1 Tamanho
- **Ideal:** até 20 linhas (Clean Code original)
- **Recomendado para Delphi:** até 50 linhas
- **Tolerância máxima:** +5 linhas (55 total)
- **Acima de 100 linhas:** Long Method — documentar como Code Smell
- **Acima de 300 linhas:** Crítico
- **Acima de 500 linhas:** God Method — 🚨 CRÍTICO

### 2.2 Parâmetros (Políade)
- **0–2 parâmetros:** ideal
- **3 parâmetros:** tolerável
- **4+ parâmetros:** Políade — Code Smell crítico

```pascal
// RUIM — Políade (7 parâmetros)
procedure OnEnviarNotasACBR(ADataSaida: TDate; AHoraSaida: TTime;
  APreVisualizar: Boolean; ASelectedList: TwwBookmarkList;
  ADataEmissao: TDateTime; AContingSVC: Boolean;
  AEmissaoEmLotes: Boolean);

// BOM — usar Record para agrupar parâmetros relacionados
type
  TParametrosEmissaoNFe = record
    DataSaida: TDate;
    HoraSaida: TTime;
    PreVisualizar: Boolean;
    DataEmissao: TDateTime;
    ContingSVC: Boolean;
    EmissaoEmLotes: Boolean;
  end;

procedure EnviarNotasACBR(const AParametros: TParametrosEmissaoNFe;
  ASelectedList: TwwBookmarkList);
```

### 2.3 Responsabilidade Única
Cada método faz UMA coisa. Se você precisa escrever "e" na descrição do método, está errado.

```pascal
// RUIM — faz tudo ao mesmo tempo (God Method)
procedure TFPedidos.GravarPedido; // 1030 linhas fazendo validação, cálculo, gravação, NF-e, e-mail...

// BOM — responsabilidades separadas
procedure TfrmPedidos.BtnSalvarClick(Sender: TObject);
begin
  if not ValidarCamposObrigatorios then Exit;
  if not ConfirmarGravacao then Exit;
  SalvarPedido;
end;

procedure TPedidoService.SalvarPedido(const APedido: TPedido);
begin
  ValidarPedido(APedido);
  CalcularTotais(APedido);
  GravarNoBancoDeDados(APedido);
end;
```

### 2.4 Guard Clauses (uso correto de Exit)
O `Exit` é permitido apenas no início do método como cláusula de guarda:

```pascal
// BOM — guard clauses
procedure TfrmPedidos.SalvarClick(Sender: TObject);
begin
  if not ValidarCliente then Exit;
  if not ValidarItens then Exit;
  if not ConfirmarOperacao then Exit;

  // código principal aqui, sem if aninhados
  SalvarPedido;
end;
```

### 2.5 Result em Functions

```pascal
// RUIM — variável auxiliar desnecessária
function CalcularDesconto(const AValor: Double; const APercentual: Double): Double;
var LDesconto: Double;
begin
  LDesconto := AValor * APercentual / 100;
  Result := LDesconto;
end;

// BOM — usar Result diretamente
function CalcularDesconto(const AValor: Double; const APercentual: Double): Double;
begin
  Result := AValor * APercentual / 100;
end;
```

---

## 3. Comentários

### 3.1 Comentários que explicam o "porquê" (bons)
```pascal
// Regra Fiscal: ICMS deve ser calculado antes do IPI conforme IN 971/2009
LBaseICMS := CalcularBaseICMS(AItem);
```

### 3.2 Comentários que explicam o "como" (ruins — o código deve ser autoexplicativo)
```pascal
// RUIM — o nome já diz o que faz
// Incrementa o contador
LContador := LContador + 1;

// Verifica se o cliente está ativo
if LCliente.Ativo then
```

### 3.3 Dead Code comentado (Code Smell)
```pascal
// RUIM — remover código comentado; o Git guarda o histórico
{ procedure TFPedidos.TabelaAfterRefresh(DataSet: TDataSet);
begin
  TbPed_Prods.CloseOpen(True);
  TbPed_Servs.CloseOpen(True);
end; }
```

---

## 4. Formatação

### 4.1 Indentação e Margem
- 2 espaços por nível — NUNCA TABs
- Margem direita: 120 caracteres
- Comandos que ultrapassam a margem: quebrar linha com 2 espaços adicionais

### 4.2 Begin/End e Else
```pascal
// RUIM
procedure Exemplo; begin
  if Condicao then begin x := 1; end
  else begin x := 2; end;
end;

// BOM
procedure Exemplo;
begin
  if Condicao then
  begin
    x := 1;
  end
  else
  begin
    x := 2;
  end;
end;
```

### 4.3 Declaração de Uses
```pascal
// RUIM — tudo numa linha
uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms;

// BOM — uma por linha, agrupadas por origem
uses
  // RTL/VCL
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  // Third-party
  FireDAC.Comp.Client,
  FastReport,
  // Projeto
  Sistema.Model.Cliente,
  Sistema.Service.Pedido;
```

### 4.4 Declaração de Variáveis
```pascal
// RUIM — múltiplas variáveis por linha
var LNome, LSobrenome: string; LIdade, LCodigo: Integer;

// BOM — uma por linha, agrupadas por tipo
var
  LNome: string;
  LSobrenome: string;
  LIdade: Integer;
  LCodigo: Integer;
```

---

## 5. Tratamento de Exceções

```pascal
// RUIM — múltiplos recursos num único try..finally
procedure Exemplo;
var LQuery1, LQuery2: TFDQuery;
begin
  LQuery1 := TFDQuery.Create(nil);
  LQuery2 := TFDQuery.Create(nil);
  try
    // ...
  finally
    LQuery1.Free;
    LQuery2.Free; // se LQuery1.Free lançar exceção, LQuery2 vaza!
  end;
end;

// BOM — um recurso por try..finally
procedure Exemplo;
var LQuery1, LQuery2: TFDQuery;
begin
  LQuery1 := TFDQuery.Create(nil);
  try
    LQuery2 := TFDQuery.Create(nil);
    try
      // ...
    finally
      LQuery2.Free;
    end;
  finally
    LQuery1.Free;
  end;
end;
```

---

## 6. Princípios SOLID em Delphi

### SRP — Single Responsibility Principle
Cada classe/unit tem uma única razão para mudar.
```pascal
// RUIM — unit de pedidos com cálculo fiscal, envio de e-mail e log
// BOM — TPedidoService, TCalculoFiscalService, TEmailService, TLogService separados
```

### OCP — Open/Closed Principle
Aberto para extensão, fechado para modificação. Usar herança e interfaces.

### DIP — Dependency Inversion Principle
Depender de abstrações (interfaces), não de implementações:
```pascal
// RUIM — dependência direta
FServico := TClienteServiceFireDAC.Create;

// BOM — dependência em interface
FServico: IClienteService;
FServico := TClienteServiceFireDAC.Create;
```

---

## 7. Programação Fluente (Fluent Interface)

Alternativa elegante ao Políade — reduz parâmetros usando encadeamento:

```pascal
// RUIM — Políade
procedure ConfigurarRelatorio(ATitulo: string; AData: TDate;
  AFiltroAtivos: Boolean; AOrdenacao: string; AExibirTotais: Boolean);

// BOM — Programação Fluente
TRelatorio.Novo
  .ComTitulo('Relatório de Clientes')
  .ParaData(Date)
  .SomenteAtivos
  .OrdenadoPor('Nome')
  .ComTotais
  .Gerar;
```
