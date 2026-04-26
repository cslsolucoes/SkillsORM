# Padrões Comportamentais — quando usar cada um

## Tabela de decisão rápida

| Problema | Pattern | Pergunta-chave |
|----------|---------|----------------|
| Algoritmo intercambiável em runtime | **Strategy** | "Vou trocar o algoritmo sem alterar o contexto?" |
| Reação automática a mudança de estado | **Observer** | "N objetos precisam saber quando Y mudou?" |
| Operação reversível com histórico | **Command** | "Preciso de Undo/Redo ou macro?" |
| Responsabilidade distribuída em cadeia | **Chain of Responsibility** | "Tenho handlers hierárquicos — alçada, validação, filtro?" |
| Componentes que se afetam mutuamente | **Mediator** | "Quero eliminar dependências cruzadas entre componentes?" |
| Comportamento muda conforme estado interno | **State** | "Objeto se comporta diferente dependendo de fase/modo?" |
| Percorrer coleção customizada com for..in | **Iterator** | "Quero separar lógica de iteração da coleção?" |

---

## Strategy

**Sinal de uso:** `if tipo = 'A' then X.Sort else Y.Sort` — algoritmo dentro de if/case.

```pascal
// Anti-pattern:
if FTipoSort = 'bubble' then BubbleSort(Arr)
else if FTipoSort = 'quick' then QuickSort(Arr);

// Com Strategy:
FSortStrategy.Sort(Arr);  // troca a estratégia sem alterar o contexto
```

---

## Observer

**Sinal de uso:** vários objetos precisam reagir quando um valor muda.

```pascal
// Anti-pattern:
procedure TValor.SetValor(V: Currency);
begin
  FValor := V;
  FLabel.Caption := CurrToStr(V);  // acoplamento direto
  FGrafico.Atualizar(V);           // idem
end;

// Com Observer:
procedure TValor.SetValor(V: Currency);
begin FValor := V; Notificar('valor_mudou', TValue.From<Currency>(V)); end;
```

---

## Command

**Sinal de uso:** precisa de histórico de ações, undo, replay ou macro.

```
Sem Command: Undo implementado na própria tela (estado salvo manualmente)
Com Command: TCommandHistory.Desfazer — pilha genérica independente da UI
```

---

## Chain of Responsibility

**Sinal de uso:** validação em múltiplos níveis, aprovação por alçada, pipeline de filtros.

```
Filtro Score → Analista → Supervisor → Gerente → Diretor
Cada handler: processa se pode, delega se não pode
```

---

## Mediator

**Sinal de uso:** N componentes que se referenciam mutuamente (UI com muitas interdependências).

```
Sem Mediator:
  BtnLogin → chama SetEnabled(BtnCancelar, False)
  BtnLogin → chama Mensagem.SetTexto(...)
  BtnLogin → chama Menu.Mostrar(...)
  (N² dependências)

Com Mediator:
  BtnLogin → Notificar('btn_login_click')
  Mediador → coordena todas as reações
  (N dependências — cada componente conhece só o mediador)
```

---

## State

**Sinal de uso:** objeto tem comportamento radicalmente diferente por fase/status.

```pascal
// Anti-pattern: condicional por estado espalhado em vários métodos
procedure TPedido.Enviar;
begin
  if FStatus = 'pago' then ...
  else if FStatus = 'confirmado' then raise ...
  else raise ...;
end;

// Com State: cada estado encapsula seu próprio comportamento
ACtx.SetEstado(TEstadoPago.Create);
ACtx.Enviar;  // delega ao estado atual — sem if/case
```

---

## Iterator

**Sinal de uso:** percorrer coleção customizada sem expor sua estrutura interna.

```pascal
// Basta implementar GetEnumerator retornando objeto com MoveNext + Current
function TCatalogo.GetEnumerator: TProdutoEnumerator;
begin Result := TProdutoEnumerator.Create(FItems.ToArray); end;

// Uso automático:
for var P in Catalogo do Writeln(P.Nome);
```
