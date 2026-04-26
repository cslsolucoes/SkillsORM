# Formatação e Estilo — Delphi Style Guide

## 1. Indentação e Margem

- **2 espaços** por nível de indentação — NUNCA TAB
- **Margem direita: 120 caracteres** — linha mais longa permitida
- Comandos além da margem: quebrar com 2 espaços adicionais de indentação
- Sintaxe fluente: levar o `.` para a nova linha

```pascal
// ✅ Sintaxe fluente correta
TMultiDialog4FMX
  .Dialog
  .SetTitle('Confirmação')
  .SetMessage('Deseja continuar?')
  .Buttons
    .AddButton('Sim', procedure begin Confirmar; end)
    .AddButton('Não', nil)
  .&End
  .Show;
```

## 2. Begin/End

- Todo bloco `if`, `while`, `for`, `repeat` deve ter `begin..end`
- Exceção: linha única pode omitir `begin..end`
- `begin` em **linha própria** — nunca na mesma linha do comando
- `end` alinhado ao `begin`

```pascal
// ✅ CORRETO
if LAtivo then
begin
  ProcessarCliente;
  AtualizarTela;
end;

// ✅ Exceção permitida (linha única)
if not LAtivo then Exit;

// ❌ ERRADO
if LAtivo then begin ProcessarCliente; end;
```

## 3. Else

- `else` sempre em **linha isolada**
- Nunca junto ao `end` anterior

```pascal
// ✅ CORRETO
if LCondicao then
begin
  Acao1;
end
else
begin
  Acao2;
end;

// ❌ ERRADO
if LCondicao then begin Acao1; end else begin Acao2; end;
```

## 4. Palavras Reservadas

Sempre em minúsculo:
`begin`, `end`, `if`, `then`, `else`, `while`, `for`, `do`, `repeat`, `until`,
`case`, `of`, `try`, `except`, `finally`, `raise`, `function`, `procedure`,
`class`, `type`, `var`, `const`, `uses`, `interface`, `implementation`,
`string`, `array`, `record`, `object`

Tipos primitivos respeitam grafia original:
`Integer`, `Double`, `Boolean`, `Char`, `Currency`, `Extended`, `Byte`

## 5. Parênteses

- Sem espaço entre `(` e o próximo caractere
- Sem espaço entre o caractere anterior e `)`
- Sem espaço entre nome do método e `(`

```pascal
// ✅ CORRETO
LValor := CalcularICMS(ABase, AAliquota);

// ❌ ERRADO
LValor := CalcularICMS( ABase, AAliquota );
LValor := CalcularICMS (ABase, AAliquota);
```

## 6. Declaração de Variáveis

Uma variável por linha, agrupadas por tipo:

```pascal
// ✅ CORRETO
var
  LNome: string;
  LSobrenome: string;
  LIdade: Integer;
  LValorTotal: Currency;
  LCliente: TCliente;

// ❌ ERRADO
var LNome, LSobrenome: string; LIdade, LCodigo: Integer;
```

## 7. Cláusula Uses

Uma unit por linha, organizada do genérico para o específico:

```pascal
uses
  // RTL / System
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  // VCL ou FMX
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  // FireDAC
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  // Terceiros
  FastReport,
  ACBrNFe,
  // Projeto — do genérico para o específico
  Sistema.Model.Cliente,
  Sistema.Service.Pedido,
  Sistema.Repository.Pedido;
```

## 8. Delimitadores em Declarações

Vírgula e ponto-e-vírgula junto ao token anterior, espaço antes do próximo:

```pascal
// ✅ CORRETO
procedure Calcular(const ANome: string; AValor: Currency; AQuantidade: Integer);

// ❌ ERRADO
procedure Calcular( const ANome : string ; AValor : Currency );
```

## 9. Cláusulas de Seção

Separar seções com uma linha em branco:

```pascal
type
  TCliente = class
  strict private
    FNome: string;
    FIdade: Integer;

  private
    procedure SetNome(const ANome: string);

  public
    constructor Create(const ANome: string; AIdade: Integer);
    destructor Destroy; override;

    property Nome: string read FNome write SetNome;
    property Idade: Integer read FIdade;
  end;
```
