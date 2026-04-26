# DUnitX Assert API — Referencia Completa

**Skill:** developer-delphi-testing-dunitx_V1.0.0

---

## Igualdade

| Metodo | Descricao |
|--------|-----------|
| `Assert.AreEqual(Exp, Act)` | Falha se `Exp <> Act` |
| `Assert.AreEqual(Exp, Act, 'msg')` | Idem com mensagem de contexto |
| `Assert.AreEqual(Exp, Act, Tolerancia)` | Para Double/Single com epsilon |
| `Assert.AreNotEqual(A, B)` | Falha se `A = B` |

```pascal
Assert.AreEqual(42, Resultado);
Assert.AreEqual('esperado', Texto, 'Texto deve ser "esperado"');
Assert.AreEqual(3.14, Calculo, 0.001); // tolerancia de 0.001
Assert.AreNotEqual(0, Contagem);
```

---

## Booleano

| Metodo | Descricao |
|--------|-----------|
| `Assert.IsTrue(Cond)` | Falha se `Cond = False` |
| `Assert.IsTrue(Cond, 'msg')` | Idem com mensagem |
| `Assert.IsFalse(Cond)` | Falha se `Cond = True` |
| `Assert.IsFalse(Cond, 'msg')` | Idem com mensagem |

---

## Nulidade

| Metodo | Descricao |
|--------|-----------|
| `Assert.IsNull(Obj)` | Falha se `Obj <> nil` |
| `Assert.IsNotNull(Obj)` | Falha se `Obj = nil` |
| `Assert.IsNull(Obj, 'msg')` | Idem com mensagem |

```pascal
Assert.IsNull(Servico, 'Servico deve ser nil antes do Setup');
Assert.IsNotNull(Conexao, 'Conexao nao deve ser nil apos inicializar');
```

---

## Excecoes

| Metodo | Descricao |
|--------|-----------|
| `Assert.WillRaise(Proc, EClasse)` | Falha se o proc NAO lancar EClasse |
| `Assert.WillRaise(Proc, EClasse, 'msg')` | Idem com mensagem |
| `Assert.WillNotRaise(Proc)` | Falha se o proc LANCAR qualquer excecao |
| `Assert.WillNotRaise(Proc, 'msg')` | Idem com mensagem |

```pascal
Assert.WillRaise(
  procedure begin Servico.Processar(nil) end,
  EArgumentNilException,
  'Processar com nil deve lancar EArgumentNilException');

Assert.WillNotRaise(
  procedure begin Servico.Inicializar end,
  'Inicializar nao deve lancar excecao');
```

---

## Strings

| Metodo | Descricao |
|--------|-----------|
| `Assert.Contains(Substring, Texto)` | Falha se Substring nao estiver em Texto |
| `Assert.StartsWith(Prefixo, Texto)` | Falha se Texto nao comecar com Prefixo |
| `Assert.EndsWith(Sufixo, Texto)` | Falha se Texto nao terminar com Sufixo |

```pascal
Assert.Contains('erro', MensagemLog, 'Log deve conter "erro"');
Assert.StartsWith('PRE-', Codigo, 'Codigo deve comecar com "PRE-"');
Assert.EndsWith('.pas', NomeArquivo, 'Arquivo deve terminar com ".pas"');
```

---

## Tipos e heranca

| Metodo | Descricao |
|--------|-----------|
| `Assert.InheritsFrom(TBase, TDerived)` | Falha se TDerived nao herdar de TBase |
| `Assert.IsType<T>(Obj)` | Falha se Obj nao for do tipo T |

```pascal
Assert.InheritsFrom(TStrings, TStringList);
Assert.IsType<TStringList>(MinhaLista);
```

---

## Colecoes

| Metodo | Descricao |
|--------|-----------|
| `Assert.IsEmpty(Lista)` | Falha se Count > 0 |
| `Assert.IsNotEmpty(Lista)` | Falha se Count = 0 |

```pascal
Assert.IsEmpty(Erros, 'Lista de erros deve estar vazia');
Assert.IsNotEmpty(Resultados, 'Deve haver ao menos um resultado');
```

---

## Falha e skip explícitos

| Metodo | Descricao |
|--------|-----------|
| `Assert.Fail('msg')` | Falha o teste explicitamente |
| `Assert.Ignore('msg')` | Pula o teste (similar ao `[Ignore]`) |
| `Assert.Pass('msg')` | Passa explicitamente (raro; evitar) |

```pascal
Assert.Fail('Funcionalidade ainda nao implementada');
Assert.Ignore('Banco de dados de teste nao disponivel neste ambiente');
```
