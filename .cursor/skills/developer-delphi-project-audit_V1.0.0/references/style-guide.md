# Delphi Style Guide
## Baseado nas Normas de Padronização ThR Softwares v4.0.1

---

## 1. IDE e Sintaxe

### 1.1 Indentação
- Padrão: **2 espaços** por nível de indentação
- **NUNCA usar TAB** para indentação

### 1.2 Margens
- Margem direita: **120 caracteres**
- Comandos além da margem: quebrar em múltiplas linhas com 2 espaços adicionais
- Sintaxe fluente: levar o `.` para a nova linha

### 1.3 Begin/End
- Todo bloco `if`, `while`, `for` deve ter `begin..end`, exceto quando tem apenas uma linha
- `begin` deve aparecer em **sua própria linha**
- `begin` não recebe indentação extra — alinha ao comando que o precede

```pascal
// CORRETO
if Condicao then
begin
  Acao1;
  Acao2;
end
else
begin
  AcaoAlternativa;
end;

// Exceção permitida (linha única, sem begin..end)
if not Ativo then Exit;
```

### 1.4 Parênteses
- Sem espaço entre `(` e o próximo caractere
- Sem espaço entre o caractere anterior e `)`
- Sem espaço entre nome da procedure/function e `(`

### 1.5 Char Case
- **Palavras reservadas** em minúsculo: `begin`, `end`, `if`, `then`, `else`, `while`, `for`, `function`, `procedure`, `string`, `array`, `record`, `type`, `var`, `const`
- **Tipos primitivos** respeitam grafia original: `Integer`, `Double`, `Boolean`, `Char`, `String` (quando como tipo, não palavra reservada)
- Exceção: `Register` (procedimento especial)

---

## 2. Comandos

### 2.1 Comando IF
- Condições compostas: ordenar da **menor para maior complexidade** (da esquerda para a direita)
- `else` em linha isolada
- Encadeamentos de `if-if-if` → substituir por `case` quando possível

### 2.2 Comando CASE
- Valores em ordem crescente
- Cada caso indentado em relação ao `case`
- Implementação em nova linha indentada
- Blocos dentro de casos: máximo 5 linhas (incluindo `begin..end`)
- `else` alinhado ao `case`, não indentado

```pascal
case LStatus of
  0: PedidoAberto;
  1: PedidoConfirmado;
  2: PedidoFaturado;
  3: PedidoCancelado;
else
  StatusDesconhecido;
end;
```

### 2.3 Comandos PROIBIDOS
| Comando | Status | Justificativa |
|---|---|---|
| `with` | 🚫 PROIBIDO | Dificulta depuração, confunde compilador |
| `Break` | 🚫 PROIBIDO | Condicional de saída deve estar no loop |
| `Continue` | 🚫 PROIBIDO | Desvio dificulta compreensão |
| `goto` | 🚫 PROIBIDO | — |
| `Exit` | ⚠️ RESTRITO | Apenas em guard clauses no início do método |

---

## 3. Exceções

### 3.1 Try..Finally
- **Obrigatório** para liberar recursos cuja liberação é responsabilidade do desenvolvedor
- **Um recurso por bloco** (prática segura)

```pascal
// CORRETO — um recurso por try..finally
LObj1 := TClasse1.Create;
try
  LObj2 := TClasse2.Create;
  try
    // uso dos objetos
  finally
    LObj2.Free;
  end;
finally
  LObj1.Free;
end;
```

### 3.2 Try..Except
- Usar **apenas quando há uma reação necessária** ao erro
- Não usar apenas para exibir mensagem (responsabilidade do tratador padrão da aplicação)
- Não capturar `Exception` genérica sem relançar

---

## 4. Camel Case

### 4.1 Regras
- Identificadores compostos: cada palavra inicia com **letra maiúscula**
- **Sem underline** (exceto constantes)
- Siglas permanecem em **maiúsculo**: `CalcularICMS`, `ValidarCNPJ`, `BuscarCEP`

---

## 5. Constantes e Variáveis Globais

### 5.1 Constantes
- Globais: **desaconselhadas** — declarar dentro da classe/método
- Nomenclatura: `CAIXA_ALTA` com `C_` como prefixo
- Separar palavras com underline

```pascal
const
  C_MAX_TENTATIVAS = 3;
  C_SQL_BUSCAR_CLIENTE = 'SELECT * FROM CLIENTES WHERE CODCLIENTE = :COD';
  C_STATUS_ATIVO = 1;
```

### 5.2 Variáveis Globais
- **PROIBIDAS** — usar `class var` como alternativa

---

## 6. Tipos

### 6.1 Nomenclatura
- Tipos derivados: prefixo `T` maiúsculo + CamelCase
- Ponteiros: prefixo `P` maiúsculo
- Exceções: prefixo `E` maiúsculo

### 6.2 Tipos Enumerados
- Prefixo de 2+ letras minúsculas mnemônicas ao tipo

```pascal
type
  TStatusPedido = (spAberto, spConfirmado, spFaturado, spCancelado);
  TTipoCliente  = (tcPessoaFisica, tcPessoaJuridica, tcEstrangeiro);
```

### 6.3 Tipos de Ponto Flutuante
| Tipo | Uso |
|---|---|
| `Currency` | **Preferido** para valores monetários (evita arredondamento) |
| `Double` | Cálculos científicos, não monetários |
| `Extended` | Apenas quando estritamente necessário (tamanho não otimizado) |
| `Real` | **PROIBIDO** — obsoleto, existe só por compatibilidade com Pascal |

---

## 7. Classes

### 7.1 Nomenclatura
- Prefixo `T` + CamelCase: `TClienteService`, `TPedidoRepository`, `TCalculoICMS`
- Exceções herdam de `Exception` com prefixo `E`: `EClienteNaoEncontrado`

### 7.2 Escopos de Visibilidade
Ordem preferencial: do mais restritivo ao menos restritivo:
```pascal
TMinhaClasse = class
strict private
  FAtributo: string;
private
  FOutroAtributo: Integer;
protected
  procedure MetodoProtegido;
public
  property Atributo: string read FAtributo write SetAtributo;
published
  // apenas para componentes
end;
```

### 7.3 Fields (Atributos)
- Sempre em `private` ou `strict private` (preferencialmente `strict private`)
- Prefixo `F` + CamelCase: `FValorTotal`, `FCodCliente`, `FNome`

### 7.4 Métodos
- Nomes significativos com verbo no infinitivo: `CalcularICMS`, `ValidarCPF`, `SalvarPedido`
- CamelCase
- Tipo de retorno: `:` junto ao nome, espaço antes do tipo: `function GetNome: string;`
- Getters: prefixo `Get`; Setters: prefixo `Set`
- Parâmetros: prefixo `A` + CamelCase (`AValor`, `ANome`, `ACodigo`)
- Parâmetros **sem** prefixos de tipo (`s`, `i`, `d` etc.)
- Sempre usar `const` em parâmetros quando possível
- Resultado de function: escrever direto em `Result`
- Variáveis locais: prefixo `L` + CamelCase

### 7.5 Propriedades
- CamelCase sem prefixo: `ValorTotal`, `CodCliente`, `Nome`

---

## 8. Métodos Anônimos

- Declarar em nova linha com 2 espaços de indentação
- `begin` do método anônimo: nova linha alinhada à declaração
- Demais regras de nomenclatura e parâmetros se aplicam

---

## 9. Componentes

### 9.1 Prefixos Padrão

| Componente | Prefixo |
|---|---|
| TButton | `btn` |
| TEdit | `edt` |
| TLabel | `lbl` |
| TComboBox | `cbx` |
| TListBox | `lst` |
| TPanel | `pnl` |
| TGroupBox | `grp` |
| TImage | `img` |
| TTimer | `tmr` |
| TDBGrid | `grd` |
| TDataSource | `dts` |
| TFDQuery / TQuery | `qry` |
| TFDConnection | `cnn` |
| TPageControl | `pgc` |
| TTabSheet | `tbs` |
| TMemo | `mmo` |
| TCheckBox | `chk` |
| TRadioButton | `rdb` |
| TDateTimePicker | `dtp` |
| TSpeedButton | `spb` |
| TBitBtn | `bbt` |
| TStringGrid | `sgr` |

### 9.2 Regra
- Todo componente **referenciado via código** deve ser renomeado com o prefixo + nome significativo
- Componentes não referenciados: tolerável manter nome default

---

## 10. Organização de Declarações

### Uses
```pascal
uses
  // RTL
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  // VCL
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  // FireDAC
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  // Third-party
  FastReport,
  ACBrNFe,
  // Projeto — por módulo
  Sistema.Model.Cliente,
  Sistema.Service.Pedido,
  Sistema.Repository.Pedido;
```

### Variáveis
```pascal
var
  // Booleanos
  LAtivo: Boolean;
  LProcessado: Boolean;
  // Inteiros
  LCodigo: Integer;
  LQuantidade: Integer;
  // Strings
  LNome: string;
  LDescricao: string;
  // Objetos
  LCliente: TCliente;
  LQuery: TFDQuery;
```
