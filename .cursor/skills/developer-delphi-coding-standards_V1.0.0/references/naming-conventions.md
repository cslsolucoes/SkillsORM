# Convenções de Nomenclatura — Delphi Style Guide

## 1. CamelCase

Todos os identificadores usam CamelCase (cada palavra inicia com maiúscula).
Siglas permanecem em MAIÚSCULO: `CalcularICMS`, `ValidarCNPJ`, `BuscarCEP`.

## 2. Prefixos por Escopo

| Escopo | Prefixo | Exemplos |
|---|---|---|
| Field (atributo privado) | `F` | `FNome`, `FValorTotal`, `FCodCliente` |
| Parâmetro de método | `A` | `ANome`, `AValor`, `ACodigo`, `AAliquota` |
| Variável local | `L` | `LNome`, `LQryAux`, `LValorICMS` |
| Constante | `C_` | `C_MAX_TENTATIVAS`, `C_SQL_BUSCAR_CLIENTE` |
| Classe | `T` | `TCliente`, `TPedidoService`, `TCalculoICMS` |
| Interface | `I` | `IClienteService`, `IRepository`, `IPedido` |
| Exceção (herda Exception) | `E` | `EClienteNaoEncontrado`, `EPedidoInvalido` |
| Ponteiro | `P` | `PCliente`, `PNodo` |

### Proibições de Prefixo

- ❌ `p` como parâmetro — confunde com ponteiro Pascal
- ❌ Notação húngara: `sNome`, `iCount`, `bAtivo`, `dValor`
- ❌ Underline em identificadores (exceto `C_` em constantes)
- ❌ Abreviações obscuras: `Vlr`, `Qtd`, `Func` → usar `Valor`, `Quantidade`, `Funcionario`

## 3. Métodos e Funções

- Nomes significativos com **verbo no infinitivo**: `CalcularICMS`, `ValidarCPF`, `SalvarPedido`
- CamelCase sem prefixo
- Getter: prefixo `Get` — `GetNome`, `GetValorTotal`
- Setter: prefixo `Set` — `SetNome`, `SetValorTotal`

## 4. Tipos Enumerados

Prefixo de 2+ letras minúsculas mnemônicas ao nome do tipo:

```pascal
type
  TStatusPedido  = (spAberto, spConfirmado, spFaturado, spCancelado);
  TTipoCliente   = (tcPessoaFisica, tcPessoaJuridica, tcEstrangeiro);
  TModalidadePag = (mpDinheiro, mpCredito, mpDebito, mpPIX);
```

Delimitadores: vírgula junto ao item anterior, espaço antes do próximo.

## 5. Constantes

```pascal
const
  C_MAX_TENTATIVAS     = 3;
  C_PRAZO_MAXIMO_DIAS  = 30;
  C_ALIQUOTA_ICMS_SP   = 0.175;
  C_SQL_BUSCAR_CLIENTE =
    'SELECT CODCLIENTE, NOME FROM CLIENTES WHERE CODCLIENTE = :COD';
```

- Globais: **desaconselhadas** — declarar dentro da classe quando possível
- Prefixo `C_` obrigatório
- Corpo em UPPER_CASE com underline separando palavras

## 6. Componentes Visuais

Todo componente referenciado via código deve ser renomeado.
Ver `component-prefixes.md` para tabela completa.

```pascal
// ❌ ERRADO — nome default
Button1.Enabled := False;
Edit1.Text := '';

// ✅ CORRETO — renomeado com prefixo
btnSalvar.Enabled := False;
edtNomeCliente.Text := '';
```

## 7. Variáveis Globais

**Proibidas.** Usar `class var` como alternativa:

```pascal
type
  TConfiguracao = class
  strict private
    class var FInstancia: TConfiguracao;
  public
    class function Instancia: TConfiguracao;
  end;
```
