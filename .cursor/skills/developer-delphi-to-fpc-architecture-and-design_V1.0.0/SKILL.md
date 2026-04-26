---
name: developer-delphi-to-fpc-architecture-and-design
description: Arquitetura modular, facades, DI/IoC por interfaces, padrões Fluent/Factory e estratégia de evolução de schema.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-architecture-and-design

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill cobre decisões de arquitetura modular para projetos Delphi/FPC: fronteiras de módulos, contratos por interfaces (`I*`), injeção de dependência via constructor + Factory `New`, padrões Fluent e estratégia de evolução de schema (scripts up/down). Ela NÃO executa build, NÃO diagnostica erros de compilação e NÃO faz tuning de performance — cada um desses domínios tem sua própria skill especializada.

## When to use
- Definição arquitetural de projeto/módulo e decisões de desenho.
- Criação ou revisão de contratos de interface entre módulos.
- Planejamento de evolução de schema (migrations up/down).
- Implementação de padrões Fluent/Factory em unidades novas.

## When NOT to use
- Não usar para tuning de build/compilação → use `developer-delphi-to-fpc-build`.
- Não usar para diagnóstico de exceções ou rastreamento de erros → use `developer-delphi-to-fpc-error-handling-and-diagnostics`.
- Não usar para otimização de performance ou gestão de memória → use `developer-delphi-to-fpc-performance-and-memory`.
- Não usar para criar/manter documentação técnica de skills → use `developer-delphi-documentation-governance`.
- Não usar para configurar diretivas `{$IFDEF}` de engine/módulo → use `developer-delphi-programming-conditional-defines`.
- Não usar quando o pedido for implementar código a partir de documentação existente → use `developer-delphi-docs-to-structured-code`.

## Inputs
- Requisitos funcionais, não funcionais e documentação técnica.
- Estrutura atual de módulos e dependências existentes.

## Workflow executável
1. Definir fronteiras de módulos (`Main`, `Modulos`, `Commons`, `Views`).
2. Modelar contratos por interfaces (`I*`) + implementações (`T*`).
3. Aplicar DI/IoC por constructor injection e Factory `New`.
4. Definir estratégia de schema evolution (scripts up/down).

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-programming-conditional-defines` | Antes de definir quais engines/módulos estarão disponíveis nas interfaces |
| `developer-delphi-to-fpc-language-core` | Antes de modelar generics, RTTI ou anonymous methods nos contratos |

## Checklist Delphi+FPC
- [ ] Compilação sem hints/warnings em Delphi (dcc32 + dcc64)
- [ ] Compilação sem hints/warnings em FPC (fpc32 + fpc64)
- [ ] Memory management: Create/Free em try..finally; sem leaks (ReportMemoryLeaksOnShutdown)
- [ ] Tratamento de exceções: hierarquia do projeto (EProviderError ou equivalente)
- [ ] Nomenclatura: prefixos T/I/E/F/A conforme documentation-project-expert
- [ ] Diretivas {$IFDEF} conforme developer-delphi-programming-conditional-defines; sem mistura com paths
- [ ] Separação UI/lógica: zero SQL ou regras de negócio em event handlers
- [ ] Plano inclui validação cross-compiler
- [ ] Referências a compile.md e diretivas_compilacao.md verificadas quando aplicável
- [ ] Sem dependência de framework Delphi-only no núcleo.
- [ ] Dependências entre módulos via interface.
- [ ] Estratégia de migração de schema documentada.

## Exemplo mínimo compilável

**Delphi (dcc32 / dcc64):**
```pascal
program SampleArchDelphi;
{$APPTYPE CONSOLE}
begin
  WriteLn('OK -- developer-delphi-to-fpc-architecture-and-design');
end.
```

**Free Pascal (fpc32 / fpc64):**
```pascal
program SampleArchFPC;
{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
{$APPTYPE CONSOLE}
begin
  WriteLn('OK -- developer-delphi-to-fpc-architecture-and-design');
end.
```

**Unit de referência (Delphi + FPC):**
```pascal
unit Sample.Arch;
{$IF DEFINED(FPC)}
  {$mode delphi}
  {$H+}
{$ENDIF}
interface

type
  IRepository = interface
    ['{84E6BAFC-0425-4F83-B6AC-7702FA1B4D52}']
    function Count: Integer;
  end;

  IService = interface
    ['{C15C9418-74A2-4D90-AF7A-3D4E6AFCB3AB}']
    function Execute: Integer;
  end;

  TService = class(TInterfacedObject, IService)
  private
    FRepo: IRepository;
  public
    constructor Create(const ARepo: IRepository);
    class function New(const ARepo: IRepository): IService;
    function Execute: Integer;
  end;

implementation

constructor TService.Create(const ARepo: IRepository);
begin
  inherited Create;
  FRepo := ARepo;
end;

class function TService.New(const ARepo: IRepository): IService;
begin
  Result := TService.Create(ARepo);
end;

function TService.Execute: Integer;
begin
  Result := FRepo.Count;
end;

end.
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Dependência direta entre módulos (sem interface) | Cria acoplamento rígido, dificulta testes e impossibilita substituição de implementação | Introduzir `I*` como contrato; injetar via constructor ou Factory `New` |
| Herança profunda de classes concretas | Fragiliza a hierarquia e dificulta compatibilidade Delphi/FPC | Preferir composição + interfaces; limitar herança a 1-2 níveis |
| SQL ou lógica de negócio em Views/event handlers | Viola separação UI/lógica; impede reutilização e testes unitários | Mover SQL para repositórios; lógica para services; Views apenas apresentam |
| Inicialização direta de dependências dentro do objeto (`TConcreto.Create` interno) | Impede injeção de mocks em testes; viola DI | Receber dependência por parâmetro no constructor; expor via Factory `New` |
| Ausência de estratégia de schema evolution | Migrações manuais não rastreáveis; risco de inconsistência entre ambientes | Criar scripts up/down versionados em `Data/migrations/` |

## Métricas de sucesso
- Todos os módulos comunicam apenas via interfaces `I*` — zero dependência concreta entre camadas.
- Factory `New` presente em cada implementação de serviço/repositório.
- Scripts de schema evolution cobrem todas as versões do banco documentadas.
- Build Delphi e FPC (Win32 + Win64) sem hints ou warnings após refatoração arquitetural.

## Responsável principal

| Papel | Quem |
|-------|------|
| Arquiteto/revisor de design | Desenvolvedor sênior Delphi/FPC |
| Validador cross-compiler | CI/pipeline local (dcc32, dcc64, fpc32, fpc64) |
| Guardião de contratos de interface | Líder técnico do módulo |

## Avaliacao de risco e confirmacao
- Refatoração de arquitetura de módulos críticos exige confirmação prévia.

## Referencias
- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`
- Object Pascal Handbook (interfaces/design patterns)
- Object Pascal Programming (composition over inheritance)
- `E:\CSL\ProvidersORM\src` (modelo de referência)

## Changelog (este arquivo)
- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `developer-delphi-architecture-and-design`; novo prefixo canônico `developer-delphi`. Conteúdo idêntico ao V1.1.0 de origem; cross-references atualizadas para prefixo `developer-delphi-*`.
