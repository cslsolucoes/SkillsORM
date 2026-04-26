---
name: developer-delphi-coding-workflow
description: >
  Escrita de código Delphi novo seguindo rigorosamente todos os padrões: classes de serviço,
  repositório, model, form, unit utilitária, interface — com SRP, DI por construtor, try..finally,
  SQL parametrizado, guard clauses, checklist automático de nomenclatura e formatação.
  Ativar quando o usuário mencionar: criar nova classe, nova unit, novo método, novo formulário,
  novo serviço, novo repositório, nova interface, novo tipo, nova constante, ou qualquer elemento
  de código Delphi novo. Também ativa ao detectar intenção de implementar funcionalidade nova.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-coding-workflow

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | Development / Workflow |

## Responsabilidade única

Guiar a escrita de código Delphi novo aplicando automaticamente todos os padrões do
Delphi Style Guide, Clean Code e boas práticas de arquitetura (SRP, DI, try..finally, SQL params).

## When to use

- Criar qualquer elemento novo: classe, unit, método, form, interface, repositório, serviço
- Escrever código seguindo os padrões canônicos do projeto
- Refatorar código existente para conformidade com o Style Guide

## When NOT to use

- Revisar padrões e Style Guide → `developer-delphi-coding-standards`
- Auditar projeto completo → `developer-delphi-project-audit`
- Criar testes → `developer-delphi-testing-dunitx`

---

## §1 — Idioma de saída

Detecte o idioma da primeira mensagem. pt-BR (padrão) ou en-US.
Identificadores Delphi (nomes de classes, métodos, fields, prefixos) seguem a convenção
do projeto e **não são traduzidos** — apenas a prosa ao redor.

---

## §2 — Fluxo de escrita (3 etapas)

### Etapa 1 — Identificar o elemento

Perguntar ao usuário (se não informado):
- Tipo: serviço / repositório / model / form / unit utilitária / interface?
- Herança/Interface: implementa alguma interface existente?
- Responsabilidade única: o que este elemento faz (apenas uma coisa)?
- Parâmetros do construtor (dependências para injeção)?

### Etapa 2 — Esboçar antes de implementar

Apresentar para aprovação:
- Nome proposto com justificativa (prefixo `T`)
- Interface proposta (prefixo `I`)
- Responsabilidade única (SRP)
- Parâmetros do construtor

### Etapa 3 — Escrever o código completo

Gerar código final com declaração da unit, `uses` organizada, seção `interface` e
`implementation` completa, comentários apenas onde a regra de negócio não é óbvia.

---

## §3 — Checklist automático (aplicar em todo código)

### Nomenclatura
- [ ] Fields com prefixo `F`: `FNome`, `FValorTotal`
- [ ] Parâmetros com prefixo `A`: `ANome`, `AValor`
- [ ] Variáveis locais com prefixo `L`: `LNome`, `LQryAux`
- [ ] Constantes com `C_` + MAIÚSCULO: `C_MAX_TENTATIVAS`
- [ ] Classes `T`, Interfaces `I`, Exceções `E`
- [ ] Métodos com verbo no infinitivo: `CalcularICMS`, `ValidarCPF`
- [ ] Componentes renomeados: `btnSalvar`, `edtNome`

### Formatação
- [ ] Indentação de 2 espaços (sem TAB)
- [ ] Margem máxima 120 caracteres
- [ ] `begin` em linha própria
- [ ] `else` em linha própria
- [ ] Uma variável por linha; uma unit por linha no `uses`
- [ ] Palavras reservadas em minúsculo

### Estrutura
- [ ] Escopos em ordem: `strict private` → `private` → `protected` → `public` → `published`
- [ ] Fields em `strict private`
- [ ] `const` em parâmetros `string`/`record` (nunca em interfaces)
- [ ] Métodos com máximo 30 linhas
- [ ] Máximo 3 parâmetros (DTO se mais)

### Segurança e robustez
- [ ] `try..finally` para cada recurso criado (um por bloco)
- [ ] `try..except` nunca vazio
- [ ] SQL sempre com parâmetros `:param` (nunca concatenado)
- [ ] `Exit` apenas como guard clause no início

### Proibições
- [ ] Zero `with`
- [ ] Zero `Break` ou `Continue` em loops
- [ ] Zero variáveis globais (usar `class var`)
- [ ] Zero notação húngara (`sNome`, `iCount`)
- [ ] Zero `Real`

---

## §4 — Exemplo: classe de serviço com interface

```pascal
unit Sistema.Service.Cliente;

interface

uses
  System.SysUtils,
  Sistema.Model.Cliente,
  Sistema.Repository.Cliente.Interfaces;

type
  IClienteService = interface
    ['{GUID-AQUI}']
    function BuscarPorCodigo(ACodigo: Integer): TCliente;
    procedure Salvar(const ACliente: TCliente);
    procedure Excluir(ACodigo: Integer);
  end;

  TClienteService = class(TInterfacedObject, IClienteService)
  strict private
    FRepository: IClienteRepository;
  public
    constructor Create(ARepository: IClienteRepository);
    function BuscarPorCodigo(ACodigo: Integer): TCliente;
    procedure Salvar(const ACliente: TCliente);
    procedure Excluir(ACodigo: Integer);
  end;

implementation

constructor TClienteService.Create(ARepository: IClienteRepository);
begin
  inherited Create;
  FRepository := ARepository;
end;

function TClienteService.BuscarPorCodigo(ACodigo: Integer): TCliente;
begin
  if ACodigo <= 0 then
    raise EArgumentoInvalido.Create('Código de cliente inválido');
  Result := FRepository.BuscarPorCodigo(ACodigo);
end;

procedure TClienteService.Salvar(const ACliente: TCliente);
begin
  if not Assigned(ACliente) then Exit;
  if ACliente.Nome.IsEmpty then
    raise EClienteInvalido.Create('Nome do cliente é obrigatório');
  FRepository.Salvar(ACliente);
end;

procedure TClienteService.Excluir(ACodigo: Integer);
begin
  if ACodigo <= 0 then Exit;
  FRepository.Excluir(ACodigo);
end;

end.
```

---

## §5 — Padrões por tipo de elemento

| Tipo | Herda de | Interface | DI Construtor |
|------|----------|-----------|---------------|
| Serviço | `TInterfacedObject` | `I<Nome>Service` | ✅ repositório(s) |
| Repositório | `TInterfacedObject` | `I<Nome>Repository` | ✅ `TFDConnection` |
| Model/Entity | `TObject` | — | ❌ |
| Form | `TForm` | — | ❌ (usa DataModule) |
| DataModule | `TDataModule` | — | ❌ |

---

## §6 — Checklist de qualidade — Workflow

- [ ] Etapa 1 concluída (tipo e responsabilidade definidos)
- [ ] Etapa 2 aprovada pelo usuário (esboço)
- [ ] Código gerado passa no checklist §3 completo
- [ ] Após escrita: notificar que `developer-delphi-testing-dunitx` deve ser executado

## Referências cruzadas

- `developer-delphi-coding-standards` — Style Guide detalhado + references/
- `developer-delphi-testing-dunitx` — criar testes para o código gerado
- `developer-delphi-firedac-queries` — queries parametrizadas no repositório
