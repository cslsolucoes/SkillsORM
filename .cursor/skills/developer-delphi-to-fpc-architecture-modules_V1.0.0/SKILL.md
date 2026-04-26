---
name: developer-delphi-to-fpc-architecture-modules
description: Modularização em Delphi — units, packages BPL (runtime/design-time), namespaces, resolução de dependências circulares, plugin via DLL, regras de coesão e acoplamento.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-architecture-modules

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill cobre a organização modular de projetos Delphi: estrutura de units e packages (`.bpl`), distinção entre packages runtime e design-time, packages estáticos vs dinâmicos, detecção e resolução de dependências circulares entre units, dependency injection sem framework externo, arquitetura de plugin via DLL + interface, regras de coesão/acoplamento e convenções de nomenclatura por camada. Ela NÃO cobre DI de alto nível com containers full-featured nem padrões como Event Bus — essas responsabilidades pertencem a `developer-delphi-to-fpc-architecture-and-design`.

## When to use

- Decidir como dividir código em units e packages (`.bpl`).
- Resolver o erro de compilação "Circular unit reference".
- Criar um sistema de plugins carregado em runtime via DLL ou BPL.
- Definir convenções de nomenclatura de units por camada do projeto.
- Estruturar módulo com interface pública separada da implementação privada.
- Planejar deploy de packages runtime junto ao executável.

## When NOT to use

- Não usar para DI com containers, Event Bus ou padrões arquiteturais de alto nível → use `developer-delphi-to-fpc-architecture-and-design`.
- Não usar para tuning de build ou flags de compilador → use `developer-delphi-to-fpc-build`.
- Não usar para criação de documentação técnica da arquitetura → use `developer-delphi-documentation-governance`.
- Não usar para configurar diretivas `{$IFDEF}` → use `developer-delphi-programming-conditional-defines`.

## Inputs

- Estrutura atual do projeto (lista de units, dependências entre elas).
- Requisito de extensibilidade (plugin, módulo opcional).
- Mensagem de erro de circular reference do compilador.

## Workflow executável

1. Mapear dependências entre units (manualmente ou com ferramenta como Pascal Analyzer).
2. Identificar ciclos: A usa B, B usa A → circular reference.
3. Quebrar ciclo: mover tipo compartilhado para unit base; ou usar seção `implementation uses`.
4. Definir interface pública em `*.Interfaces.pas`; implementação em `*.Impl.pas`.
5. Para plugins: definir interface estável em unit compartilhada; carregar DLL/BPL em runtime.
6. Aplicar convenções de nomenclatura por camada.
7. Validar com dcc32 + dcc64 sem hints/warnings.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-architecture-and-design` | Antes de definir contratos de interface entre módulos |
| `developer-delphi-programming-conditional-defines` | Antes de criar packages com defines condicionais |
| `developer-delphi-to-fpc-build` | Antes de configurar compilação de packages BPL |

## Checklist Delphi+FPC

- [ ] Compilação sem hints/warnings em Delphi (dcc32 + dcc64)
- [ ] Compilação sem hints/warnings em FPC (fpc32 + fpc64)
- [ ] Nenhuma circular unit reference no projeto
- [ ] Interface pública em unit separada (`*.Interfaces.pas`)
- [ ] Implementação privada em unit separada (`*.Impl.pas`)
- [ ] Factory pública: `TXxxFactory.New` ou função `CreateXxx: IXxx`
- [ ] Packages runtime listados corretamente nas Requires do `.dproj`
- [ ] Plugins: interface estável definida em unit compartilhada sem dependências do app
- [ ] Nomenclatura: prefixos T/I/E/F/A conforme documentation-project-expert
- [ ] Units por camada seguem convenção (`u*`, `ufrm*`, `udata*`)

## Convenções de nomenclatura por camada

| Camada | Prefixo de unit | Exemplos |
|--------|----------------|---------|
| Domain / Entities | `u` | `uCliente.pas`, `uPedido.pas` |
| Interfaces / Contratos | `u` + sufixo `.Interfaces` | `uCliente.Interfaces.pas` |
| Implementações | `u` + sufixo `.Impl` | `uCliente.Impl.pas` |
| Repositórios | `udata` ou `u*.Repository` | `udataCliente.pas` |
| Formulários VCL/FMX | `ufrm` | `ufrm.Main.pas`, `ufrm.Cliente.pas` |
| Factories | `u*.Factory` | `uCliente.Factory.pas` |
| Utils / Helpers | `uHelpers` ou `u*.Utils` | `uHelpers.pas` |
| Plugin / DLL export | `uPlugin` | `uPlugin.Interfaces.pas` |

**Namespace Delphi (ponto como separador):**
```
Empresa.Produto.Modulo.Unit
App.Clientes.Repository.SQLite
App.Common.Types
App.Plugins.Pagamento.Interfaces
```

## Exemplo mínimo compilável

**Delphi (dcc32 / dcc64):**

```pascal
program SampleModulesDelphi;
{$APPTYPE CONSOLE}
uses SysUtils;
begin
  WriteLn('OK -- developer-delphi-to-fpc-architecture-modules');
end.
```

**Free Pascal (fpc32 / fpc64):**

```pascal
program SampleModulesFPC;
{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
{$APPTYPE CONSOLE}
uses SysUtils;
begin
  WriteLn('OK -- developer-delphi-to-fpc-architecture-modules');
end.
```

**Unit de referência — módulo com interface pública:**

```pascal
unit App.Pagamento.Interfaces;
{$IF DEFINED(FPC)}
  {$mode delphi}
{$ENDIF}
interface

type
  IPagamentoModule = interface
    ['{F1E2D3C4-B5A6-7890-ABCD-EF0123456789}']
    procedure Initialize;
    function Processar(const AValor: Double): Boolean;
    procedure Finalize;
  end;

  // Factory publica — unica forma de obter o modulo
  TPagamentoFactory = class
    class function New: IPagamentoModule;
  end;

implementation

// Implementacao em GestorERP.Pagamento.Impl.pas
// TPagamentoFactory.New e implementado la

end.
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Circular unit reference em interface section | Erro de compilação; impede build | Mover tipo compartilhado para unit base; usar `implementation uses` quando possível |
| Interface pública misturada com implementação na mesma unit | Acopla usuários da interface à implementação; dificulta substituição | Separar em `*.Interfaces.pas` e `*.Impl.pas` |
| Package runtime sem versão explícita no nome | Conflito de versões em deploy; "DLL Hell" do Delphi | Incluir versão no nome: `MeuPacote_2_1.bpl` |
| Plugin que importa units do app host | Plugin não pode ser usado em outros apps; acoplamento reverso | Plugin depende APENAS da interface compartilhada, nunca do app |
| Units muito grandes ("God Unit") com múltiplas responsabilidades | Dificulta testes, reutilização e navegação | Aplicar SRP: uma responsabilidade por unit |
| Usar `LoadLibrary` sem verificar handle | Crash ao chamar GetProcAddress com handle inválido | Sempre verificar `H <> 0` após LoadPackage/LoadLibrary |

## Métricas de sucesso

- Zero erros de "Circular unit reference" em toda a base de código.
- Cada módulo expõe apenas interface pública (`*.Interfaces.pas`) — implementação inacessível a usuários externos.
- Plugins carregam e descarregam sem leak de memória (verificado com FastMM4).
- Build Delphi e FPC (Win32 + Win64) sem hints ou warnings.

## Responsável principal

| Papel | Quem |
|-------|------|
| Arquiteto de módulos | Desenvolvedor sênior Delphi |
| Revisor de dependências | Líder técnico do projeto |
| Validador cross-compiler | CI/pipeline local |

## Avaliacao de risco e confirmacao

- Reorganização de packages BPL em projeto existente pode quebrar runtime — confirmar com usuário antes de alterar estrutura de packages.
- Mover tipos entre units pode quebrar dependências binárias — verificar se há `.dcu` distribuídos antes de refatorar.

## Referencias

- Object Pascal Handbook (Packages e namespaces)
- RAD Studio docs: Packages and Component Libraries
- `E:\CSL\ProvidersORM\src` (modelo de referência de modularização)
- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/`

## Changelog (este arquivo)

- 1.0.0 (11/04/2026): Criação inicial — SP-I1. Cobre units, BPL runtime/design-time, packages estáticos/dinâmicos, circular deps, DI manual, plugin via DLL, modularização, namespaces, convenções de nomenclatura por camada.
