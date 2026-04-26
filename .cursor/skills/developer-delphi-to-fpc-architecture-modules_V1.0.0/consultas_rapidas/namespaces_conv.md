# Convenção de Namespaces Delphi

**Skill:** `developer-delphi-to-fpc-architecture-modules_V1.0.0`
**Data:** 2026-04-11

---

## Formato canônico

```
Empresa.Produto.Modulo.Responsabilidade
```

| Segmento | Descrição | Exemplo |
|----------|-----------|---------|
| `Empresa` | Prefixo da organização | `GestorERP`, `Acme`, `CSL` |
| `Produto` | Nome do produto ou sub-sistema | `Clientes`, `Pagamento`, `Fiscal` |
| `Modulo` | Camada ou sub-módulo | `Repository`, `UseCases`, `Domain` |
| `Responsabilidade` | Papel específico da unit | `SQLite`, `Factory`, `Interfaces` |

---

## Exemplos por camada

```
GestorERP.Common.Types              ← tipos base compartilhados
GestorERP.Common.Exceptions         ← hierarquia de exceções
GestorERP.Common.Helpers            ← helpers e extensões

GestorERP.Clientes.Interfaces       ← contratos públicos do módulo
GestorERP.Clientes.Impl             ← implementação do domínio
GestorERP.Clientes.Factory          ← factory pública
GestorERP.Clientes.Repository.SQLite
GestorERP.Clientes.Repository.Memory
GestorERP.Clientes.UseCases.CriarCliente
GestorERP.Clientes.UseCases.AtualizarCliente

GestorERP.Pagamento.Interfaces
GestorERP.Pagamento.Impl
GestorERP.Pagamento.Providers.Pix
GestorERP.Pagamento.Providers.Cartao

GestorERP.Plugins.Interfaces        ← contratos de plugin
GestorERP.Plugins.Loader            ← carregamento de BPL/DLL
```

---

## Formulários VCL/FMX — convenção herdada (sem namespace)

Formulários tipicamente NÃO usam namespace completo — convenção histórica do Delphi:

| Padrão | Exemplo |
|--------|---------|
| `ufrm.` + nome descritivo | `ufrm.Main.pas`, `ufrm.Cliente.pas` |
| Classe: `TfrmNome` | `TfrmMain`, `TfrmCliente` |
| Nome do form: `frmNome` | `frmMain`, `frmCliente` |

---

## Unit Scope Names — atalho no IDE

**Onde configurar:**
`Project → Options → Delphi Compiler → Unit Scope Names`

**O que faz:**
Permite omitir o prefixo de namespace ao usar a unit em `uses`.

```pascal
// Sem Unit Scope Names:
uses GestorERP.Common.Types, GestorERP.Clientes.Interfaces;

// Com "GestorERP.Common" e "GestorERP.Clientes" em Unit Scope Names:
uses Types, Interfaces;  // ← compilador resolve automaticamente
```

**Regra de prioridade:**
- A ordem na lista de Unit Scope Names importa.
- Se `GestorERP.Common` vier antes de `System`, `Types` resolve para `GestorERP.Common.Types`.
- Para desambiguar: sempre usar o nome completo.

**Recomendação:** usar Unit Scope Names apenas para o prefixo `GestorERP.Common` (utilitários muito usados). Para módulos de domínio, preferir o nome completo para evitar ambiguidade.

---

## Mapeamento para disco

```
src/
  Commons/
    GestorERP.Common.Types.pas
    GestorERP.Common.Exceptions.pas
  Modulos/
    Clientes/
      GestorERP.Clientes.Interfaces.pas
      GestorERP.Clientes.Impl.pas
      GestorERP.Clientes.Factory.pas
      Repository/
        GestorERP.Clientes.Repository.SQLite.pas
        GestorERP.Clientes.Repository.Memory.pas
    Pagamento/
      GestorERP.Pagamento.Interfaces.pas
      GestorERP.Pagamento.Factory.pas
      Providers/
        GestorERP.Pagamento.Providers.Pix.pas
        GestorERP.Pagamento.Providers.Cartao.pas
  Views/
    ufrm.Main.pas
    ufrm.Cliente.pas
  Main/
    GestorERP.Connections.pas
    GestorERP.Database.pas
```

---

## Conflitos de namespace com a RTL do Delphi

| Unit sua | Conflito potencial com | Solução |
|----------|------------------------|---------|
| `Types` | `System.Types` | Renomear: `GestorERP.Common.Types` e não adicionar ao Unit Scope Names |
| `Generics` | `System.Generics.Collections` | Usar nome completo sempre |
| `Classes` | `System.Classes` | Evitar usar "Classes" como sufixo |
| `SysUtils` | `System.SysUtils` | Evitar usar "SysUtils" como sufixo |

**Prática segura:** nunca usar como nome de unit qualquer nome que já exista na RTL do Delphi (System.*, Vcl.*, Fmx.*).

---

## Declaração de unit com namespace

```pascal
unit GestorERP.Clientes.Repository.SQLite;
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// O nome da unit IS o namespace — sem keyword especial.
// O arquivo deve se chamar:
//   GestorERP.Clientes.Repository.SQLite.pas
// (ponto-a-ponto no nome do arquivo)

{$IF DEFINED(FPC)}
  {$mode delphi}
{$ENDIF}

interface

uses
  SysUtils,
  GestorERP.Common.Types,
  GestorERP.Clientes.Interfaces;

// ...

implementation

end.
```
