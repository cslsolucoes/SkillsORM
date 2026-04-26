---
name: developer-delphi-testing-dunitx
description: Testes unitários com DUnitX em Delphi — fixtures, assertions, TestCase parametrizado, mocking com Delphi-Mocks e isolamento de dependencias via injecao.
model: sonnet
thinking: extended
category: developer-delphi
status: superseded
superseded_by: developer-delphi-testing-dunitx_V1.1.0
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---
> **DEPRECATED** — Substituída por `developer-delphi-testing-dunitx_V1.1.0` (E10, 2026-04-24). Não usar em novos projetos.


# developer-delphi-testing-dunitx

> ⚠️ **SUPERSEDED** — Use `developer-delphi-testing-dunitx_V1.1.0`.
> Esta versão (V1.0.0) mantida apenas para referência histórica.


## Versao interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Data** | 11/04/2026 |

## Responsabilidade unica

Esta skill cobre a escrita e execucao de testes unitarios com o framework DUnitX em Delphi: estrutura de fixtures com atributos `[TestFixture]`, `[Test]`, `[Setup]`, `[TearDown]`, `[SetupFixture]`, `[TearDownFixture]`, `[TestCase]` e `[Ignore]`; API completa de `Assert`; mocking de interfaces com `Delphi.Mocks`; e tecnicas de isolamento por injecao de dependencia. Ela NÃO cobre testes de integracao com banco real (→ `developer-delphi-testing-integration`) e NÃO configura pipeline de CI (→ `developer-delphi-to-fpc-build`).

## When to use

- Escrever ou revisar testes unitarios DUnitX para classes e servicos.
- Configurar mocks de interfaces com `TMock<I>` (Delphi-Mocks).
- Definir testes parametrizados com `[TestCase]`.
- Isolar unidades de codigo por injecao de dependencia.
- Organizar setup/teardown por fixture vs. por teste.

## When NOT to use

- Nao usar para testes contra banco de dados real → use `developer-delphi-testing-integration`.
- Nao usar para configurar pipeline de CI → use `developer-delphi-to-fpc-build`.
- Nao usar para benchmarks de performance → use `developer-delphi-to-fpc-performance-profiling`.
- Nao usar para diagnostico de excecoes em runtime → use `developer-delphi-to-fpc-error-handling-and-diagnostics`.

## Inputs

- Classe ou servico a ser testado.
- Lista de comportamentos esperados (casos de teste).
- Dependencias externas que precisam ser mockadas.

## Workflow executavel

1. **Identificar unidade** — qual classe/servico sera testado; quais as dependencias.
2. **Criar interfaces para dependencias** — se a classe ainda nao usa injecao, refatorar para receber interfaces no construtor.
3. **Escrever fixture** — `[TestFixture]`, campos privados para o objeto e seus mocks.
4. **Implementar setup/teardown** — `[Setup]` cria o objeto + mocks; `[TearDown]` libera.
5. **Escrever testes** — um `[Test]` por comportamento; nomear `Dado_Quando_Entao`.
6. **Adicionar assercoes** — `Assert.AreEqual`, `Assert.Raises<E>`, etc.
7. **Verificar mocks** — `MockObj.Verify(...)` ao final de cada teste que verifica interacoes.
8. **Executar e validar** — rodar via `TDUnitX.RegisterTestFixture` + runner.

## Atributos DUnitX

| Atributo | Escopo | Descricao |
|----------|--------|-----------|
| `[TestFixture]` | Classe | Marca a classe como suite de testes |
| `[Test]` | Metodo | Marca o metodo como um caso de teste |
| `[Setup]` | Metodo | Executado ANTES de CADA teste |
| `[TearDown]` | Metodo | Executado APOS cada teste (mesmo com falha) |
| `[SetupFixture]` | Metodo | Executado UMA VEZ antes de todos os testes da fixture |
| `[TearDownFixture]` | Metodo | Executado UMA VEZ apos todos os testes da fixture |
| `[TestCase('nome','p1,p2')]` | Metodo | Teste parametrizado; pode repetir multiplas vezes |
| `[Ignore('motivo')]` | Metodo | Ignora o teste; deve ter justificativa |
| `[Category('cat')]` | Metodo/Classe | Agrupa testes para filtro por categoria |

## Assert API — Referencia completa

```pascal
// Igualdade
Assert.AreEqual(Expected, Actual);
Assert.AreEqual(Expected, Actual, 'Mensagem de contexto');
Assert.AreNotEqual(A, B);

// Booleano
Assert.IsTrue(Condicao);
Assert.IsFalse(Condicao);

// Nulidade
Assert.IsNull(Valor);
Assert.IsNotNull(Valor);

// Excecoes
Assert.WillRaise(procedure begin CodigoQueDeveRaisear end, EClasseExcecao);
Assert.WillNotRaise(procedure begin CodigoSeguro end);

// Heranca
Assert.InheritsFrom(TBase, TDerived);
Assert.IsType<TClasse>(Objeto);

// Strings
Assert.Contains('substring', StringCompleta);
Assert.StartsWith('prefixo', StringCompleta);
Assert.EndsWith('sufixo', StringCompleta);

// Colecoes
Assert.IsNotEmpty(Lista);
Assert.IsEmpty(Lista);
```

## Dependencias (skills previas)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-build` | Build limpo e sem erros antes de rodar a suite de testes |
| `developer-delphi-to-fpc-architecture-and-design` | Dependencias devem estar modeladas como interfaces antes de mockar |

## Checklist DUnitX

- [ ] Cada `[Test]` e independente — sem estado compartilhado entre testes
- [ ] `[Setup]` cria objetos frescos; `[TearDown]` libera todos
- [ ] Mocks configurados em `[Setup]`; verificados no teste antes do `TearDown`
- [ ] Nomes de teste seguem padrao `Dado_Quando_Entao` ou `ContextoMetodo_Comportamento`
- [ ] `Assert.WillRaise` cobre caminhos de erro documentados
- [ ] `[TestCase]` parametrizado para valores de borda (vazio, nulo, maximo)
- [ ] `[Ignore]` sempre tem justificativa e issue/ticket associado
- [ ] Suite executa com exit code 0 em dcc32 e dcc64

## Exemplo minimo compilavel

```pascal
program SampleDUnitXDelphi;
{$APPTYPE CONSOLE}
uses
  System.SysUtils,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit;

type
  [TestFixture]
  TExemploFixture = class
  public
    [Test]
    procedure TestSoma;
  end;

procedure TExemploFixture.TestSoma;
begin
  Assert.AreEqual(4, 2 + 2);
end;

var
  Runner: ITestRunner;
  Results: IRunResults;
begin
  TDUnitX.RegisterTestFixture(TExemploFixture);
  Runner  := TDUnitX.CreateRunner;
  Results := Runner.Execute;
  if Results.AllPassed then
    WriteLn('OK -- developer-delphi-testing-dunitx')
  else
    WriteLn('FAIL -- developer-delphi-testing-dunitx');
  Halt(Ord(not Results.AllPassed));
end.
```

## Anti-padroes

| Anti-padrao | Por que e errado | Como corrigir |
|-------------|-----------------|---------------|
| Estado compartilhado entre testes via campo de classe | Ordem de execucao afeta resultado; falhas intermitentes | Usar `[Setup]`/`[TearDown]` para estado por instancia |
| Teste que falha silenciosamente sem Assert | Sempre passa mesmo com comportamento errado | Toda verificacao deve usar um metodo de Assert |
| Mock sem `Verify` ao final | Interacoes esperadas podem nao ter ocorrido | Chamar `Mock.Verify(...)` antes do `TearDown` |
| `[Ignore]` sem justificativa | Testes esquecidos que nunca voltam a passar | Sempre incluir motivo e referencia ao ticket |
| Testar implementacao interna (campos privados) | Teste quebra a cada refatoracao interna | Testar comportamento via interface publica |
| Nenhum teste para caminho de excecao | Excecoes em producao nao cobertas | `Assert.WillRaise<ETipo>` para cada excecao documentada |

## Metricas de sucesso

- Suite executa com exit code 0 em dcc32 e dcc64.
- Zero testes `[Ignore]` sem justificativa e ticket.
- Cobertura de caminho de erro para todas as excecoes documentadas.
- Cada teste e independente: pode ser executado em qualquer ordem.

## Responsavel principal

| Papel | Quem |
|-------|------|
| Autor dos testes | Desenvolvedor responsavel pelo modulo |
| Revisor | Par no code review |

## Avaliacao de risco e confirmacao

- Se o teste acessar recursos externos (banco, arquivo, rede), ele nao e unitario — mover para `developer-delphi-testing-integration`.

## Referencias

- `exemplos/test_fixture_basico.pas` — estrutura minima de fixture
- `exemplos/setup_teardown.pas` — Setup/TearDown por teste vs. por fixture
- `exemplos/assertions.pas` — todos os Assert.* com exemplos
- `exemplos/test_case_attribute.pas` — testes parametrizados
- `exemplos/mock_interface.pas` — TMock<IService> (Delphi-Mocks)
- `exemplos/test_isolation.pas` — injecao de dependencia para isolar unidades
- `consultas_rapidas/dunitx_attributes.md` — tabela de atributos
- `consultas_rapidas/assert_api.md` — todos os metodos Assert
- `consultas_rapidas/mock_setup.md` — TMock<I>.Setup.Expect; Verify
- `templates/TEMPLATE_test_fixture.pas` — fixture completo
- `templates/TEMPLATE_mock_service.pas` — mock de servico
- DUnitX GitHub: https://github.com/VSoftTechnologies/DUnitX
- Delphi-Mocks GitHub: https://github.com/VSoftTechnologies/Delphi-Mocks

## Changelog (este arquivo)

- 1.0.0 (11/04/2026): Skill nova — SP-F1 do plano master; cobre DUnitX fixtures, Assert API completa, TestCase parametrizado, TMock<I> e isolamento por injecao de dependencia.
