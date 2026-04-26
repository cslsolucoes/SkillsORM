# DUnitX — Tabela de Atributos

**Skill:** developer-delphi-testing-dunitx_V1.0.0

---

## Atributos de classe

| Atributo | Aplica em | Efeito |
|----------|-----------|--------|
| `[TestFixture]` | Classe | Marca como suite de testes; obrigatorio |
| `[Category('nome')]` | Classe | Agrupa para filtro por categoria na linha de comando |

## Atributos de metodo

| Atributo | Aplica em | Efeito |
|----------|-----------|--------|
| `[Test]` | Metodo | Caso de teste individual; obrigatorio |
| `[Setup]` | Metodo | Executado ANTES de cada `[Test]` |
| `[TearDown]` | Metodo | Executado APOS cada `[Test]` (mesmo com falha) |
| `[SetupFixture]` | Metodo | Executado UMA VEZ antes de todos os testes da fixture |
| `[TearDownFixture]` | Metodo | Executado UMA VEZ apos todos os testes da fixture |
| `[TestCase('nome','csv')]` | Metodo `[Test]` | Parametriza o teste; pode repetir N vezes |
| `[Ignore('motivo')]` | Metodo `[Test]` | Pula o teste; deve ter justificativa |
| `[Category('nome')]` | Metodo `[Test]` | Subcategoria do caso de teste |

---

## Ciclo de vida de execucao

```
SetupFixture           (1x por fixture)
  |
  +-- Setup            (1x por teste)
  |     |
  |     +-- [Test]     (o proprio teste)
  |     |
  |     +-- TearDown   (1x por teste, mesmo com falha)
  |
  +-- Setup            (proximo teste...)
  |     ...
  |
TearDownFixture        (1x por fixture, ao final)
```

---

## [TestCase] — Sintaxe e conversao de tipos

```pascal
[Test]
[TestCase('descricao', 'param1,param2,param3')]
procedure MeuTeste(AParam1: string; AParam2: Integer; AParam3: Boolean);
```

Tipos suportados para conversao automatica de CSV:
- `string` — passado diretamente
- `Integer`, `Int64` — StrToInt64
- `Double`, `Single`, `Extended` — StrToFloat (locale-independent)
- `Boolean` — 'True'/'False' ou '1'/'0'
- `TDateTime` — StrToDateTime (locale-dependent; preferir strings ISO)

**Exemplo com multiplos tipos:**
```pascal
[TestCase('caso 1', 'Joao,25,True')]
[TestCase('caso 2', 'Maria,17,False')]
procedure Testar(const ANome: string; AIdade: Integer; AAtivo: Boolean);
```

---

## [Ignore] — Boas praticas

```pascal
// BOM: motivo claro + referencia ao ticket
[Test]
[Ignore('Aguardando definicao da regra de negocio — issue #456')]
procedure TesteEmDesenvolvimento;

// RUIM: sem motivo
[Test]
[Ignore]
procedure TesteEsquecido;  // nunca sera re-habilitado
```

---

## Registrar fixtures e executar

```pascal
// No program principal de testes:
uses DUnitX.TestFramework, MinhaFixture;

begin
  TDUnitX.RegisterTestFixture(TMinhaFixture);
  var Runner  := TDUnitX.CreateRunner;
  var Results := Runner.Execute;
  if not Results.AllPassed then
    Halt(1);
end.
```

Ou registrar na `initialization` da unit (mais comum):
```pascal
initialization
  TDUnitX.RegisterTestFixture(TMinhaFixture);
```
