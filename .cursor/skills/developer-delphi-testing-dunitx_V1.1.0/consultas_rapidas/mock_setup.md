# Delphi-Mocks — TMock<I> Referencia Rapida

**Skill:** developer-delphi-testing-dunitx_V1.0.0
**GitHub:** https://github.com/VSoftTechnologies/Delphi-Mocks

---

## Criar e usar um mock

```pascal
uses Delphi.Mocks;

var MockSvc: TMock<IServico>;
MockSvc := TMock<IServico>.Create;

// Obter a interface para injetar no objeto testado:
var Servico := TMinhaClasse.Create(MockSvc);  // TMock<I> tem conversao implicita
```

---

## Configurar valor de retorno (WillReturn)

```pascal
// Metodo que retorna string
MockSvc.Setup.WillReturn('resultado').When.BuscarNome(42);

// Metodo que retorna Boolean
MockSvc.Setup.WillReturn(True).When.Existe(42);

// Metodo que retorna Integer
MockSvc.Setup.WillReturn(100).When.Contar;

// Aceitar qualquer argumento do tipo:
MockSvc.Setup.WillReturn('ok').When.BuscarNome(It.IsAny<Integer>);
```

---

## Configurar excecao (WillRaise)

```pascal
MockSvc.Setup
  .WillRaise(EAccessViolation, 'Falha simulada')
  .When.Salvar(It.IsAny<string>);
```

---

## Configurar expectativas (Expect)

```pascal
// Deve ser chamado exatamente UMA vez
MockSvc.Setup.Expect.Once.When.Log('mensagem esperada');

// Deve ser chamado pelo menos uma vez
MockSvc.Setup.Expect.AtLeastOnce.When.Log(It.IsAny<string>);

// NUNCA deve ser chamado
MockSvc.Setup.Expect.Never.When.DeletarTudo;

// Exatamente N vezes
MockSvc.Setup.Expect.Exactly(3).When.IncrementalContador;

// Entre N e M vezes
MockSvc.Setup.Expect.Between(1, 5).When.Log(It.IsAny<string>);
```

---

## It — Matchers de argumento

| Matcher | Descricao |
|---------|-----------|
| `It.IsAny<T>` | Aceita qualquer valor do tipo T |
| `It.IsEqualTo<T>(V)` | Aceita apenas o valor V |
| `It.IsNotNil<T>` | Aceita qualquer valor nao nil |
| `It.Matches<T>(func)` | Aceita se a funcao retornar True |

```pascal
MockSvc.Setup.WillReturn(True).When.Existe(It.IsAny<Integer>);
MockSvc.Setup.WillReturn('admin').When.BuscarPerfil(It.IsEqualTo<Integer>(1));
```

---

## Verificar expectativas (Verify)

```pascal
// Verificar TODAS as expectativas da fixture:
MockSvc.Verify('Descricao do que deveria ter acontecido');

// Verificar com mensagem customizada:
MockSvc.Verify('Log deve ter sido chamado exatamente uma vez com a mensagem correta');
```

`Verify` falha o teste se alguma expectativa configurada com `Expect` nao for satisfeita.

---

## Ciclo padrao em um teste

```pascal
// 1. Setup: criar mocks
FMockRepo := TMock<IRepository>.Create;

// 2. Configurar: o que o mock deve retornar / esperar
FMockRepo.Setup.WillReturn(TCliente.Create('Joao')).When.BuscarPorId(1);
FMockRepo.Setup.Expect.Once.When.BuscarPorId(1);

// 3. Exercitar: chamar o servico
var Resultado := FServico.BuscarCliente(1);

// 4. Assertar: verificar resultado
Assert.AreEqual('Joao', Resultado.Nome);

// 5. Verificar: confirmar interacoes com o mock
FMockRepo.Verify('BuscarPorId(1) deve ter sido chamado uma vez');

// 6. TearDown: liberacao automatica via ref-count (TMock<I> e interface)
```

---

## Instalar Delphi-Mocks

**Via GetIt:** Tools > GetIt Package Manager > pesquisar "Delphi Mocks".

**Manual:** clonar https://github.com/VSoftTechnologies/Delphi-Mocks e adicionar ao Search Path:
```
<repo>\Source
```

**Dependencias:** DUnitX (deve estar no Search Path antes).
