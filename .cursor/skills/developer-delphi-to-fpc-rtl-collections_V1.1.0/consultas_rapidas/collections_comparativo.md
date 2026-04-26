# Comparativo de Coleções RTL Delphi

## Tabela de decisão rápida

| Cenário | Coleção recomendada | Motivo |
|---------|--------------------|-|
| Lista simples de valores/objetos | `TList<T>` | Flexível, memória contígua |
| Lista de objetos com auto-free | `TObjectList<T>` | OwnsObjects=True libera no Delete/Free |
| Lookup O(1) por chave | `TDictionary<K,V>` | Hash table |
| Lookup O(1) + auto-free de valores objeto | `TObjectDictionary<K,V>` | `doOwnsValues` |
| Fila FIFO (processar em ordem de chegada) | `TQueue<T>` | Enqueue/Dequeue |
| Pilha LIFO (desfazer, DFS, RPN) | `TStack<T>` | Push/Pop |
| Lista sempre ordenada + busca binária | `TSortedList<K,V>` | O(log n) por chave |
| Pipeline/transformação funcional | `TList<T>` + helpers Where/Select | Não há lazy evaluation nativa |

---

## TList\<T\>

```pascal
var L: TList<TProduto> := TList<TProduto>.Create;
L.Add(P);           // O(1) amortizado
L.Delete(I);        // O(n) — desloca elementos
L.Remove(P);        // O(n) — busca linear + desloca
L.Sort(Comparer);   // O(n log n) introsort
L.IndexOf(P);       // O(n) — linear
L[I];               // O(1)
```

**Quando usar:**
- Coleção de value types (`Integer`, `string`, records)
- Coleção de objetos onde *você* gerencia o lifetime
- Precisa de ordenação customizada frequente

**Não usar quando:** precisa de lookup por chave (→ TDictionary) ou fila/pilha

---

## TObjectList\<T\>

```pascal
var OL: TObjectList<TAnimal> := TObjectList<TAnimal>.Create;  // OwnsObjects=True
OL.Add(TCao.Create('Rex'));
OL.Delete(0);  // Free automático de Rex
OL.Free;       // Free automático de todos os restantes
```

**OwnsObjects = False:** lista emprestada — não libera. Útil para views/filtros temporários.

**Polimorfismo:** declare como `TObjectList<TAnimal>` e adicione subclasses `TCao`, `TGato`.

---

## TDictionary\<K,V\>

```pascal
var D: TDictionary<string, Integer> := TDictionary<string, Integer>.Create;
D.Add('chave', 42);           // EListError se chave duplicada
D.AddOrSetValue('chave', 99); // upsert — sem raise
D.TryGetValue('chave', V);    // seguro — sem raise
D.ContainsKey('chave');
D.Remove('chave');
for Pair in D do ...           // ordem não garantida
```

**TObjectDictionary:** use `doOwnsKeys`, `doOwnsValues` ou ambos para auto-free.

**Atenção:** iteração sobre `Keys` ou `Values` durante modificação → InvalidOperation.

---

## TQueue\<T\> — FIFO

```pascal
Q.Enqueue(Item);   // adiciona no fim
Q.Dequeue;         // remove do início (raise se vazio)
Q.TryDequeue(V);   // seguro
Q.Peek;            // vê sem remover (raise se vazio)
Q.Count;
```

**Casos de uso:** fila de tarefas, BFS (busca em largura), buffer de mensagens, pipeline produtor-consumidor.

---

## TStack\<T\> — LIFO

```pascal
S.Push(Item);   // empilha no topo
S.Pop;          // desempilha (raise se vazio)
S.TryPop(V);    // seguro
S.Peek;         // vê topo sem remover
S.Count;
```

**Casos de uso:** Undo/Redo, DFS (busca em profundidade), avaliação RPN, histórico de navegação, chamadas de método (recursão manual).

---

## TSortedList\<K,V\>

```pascal
SL.Add(30, 'trinta');  // inserido na posição correta
SL.IndexOfKey(30);     // busca binária O(log n)
SL.Keys[I];            // acesso por índice
SL.Values[I];
SL.TryGetValue(K, V);
// Iteração: ordem garantida por chave
for Pair in SL do ...
```

**Quando usar:** quando precisa de ordem garantida + lookup por chave. Inserção O(n) (desloca), busca O(log n).

**Comparer customizado:** passa no construtor para ordem não-padrão.

---

## Resumo de complexidades

| Operação | TList | TDictionary | TSortedList | TQueue | TStack |
|----------|-------|-------------|-------------|--------|--------|
| Add/Enqueue/Push | O(1)* | O(1)* | O(n) | O(1)* | O(1)* |
| Get by index | O(1) | — | O(1) | — | — |
| Lookup by key | O(n) | O(1) | O(log n) | — | — |
| Delete by index | O(n) | — | O(n) | — | — |
| Iteration | O(n) | O(n) | O(n) ordenado | O(n) | O(n) |

\* amortizado

---

## Armadilhas comuns

1. **TList com objetos** — você é responsável pelo Free individual antes de Delete/Clear
2. **TObjectList OwnsObjects=True** — nunca faça `Free` no objeto fora da lista após adicionar
3. **TDictionary iteration + modification** — causa `EInvalidOperation`; itere sobre cópia de Keys
4. **TSortedList chave duplicada** — lança `EListError`; use `AddOrSetValue` quando possível
5. **TQueue/TStack em thread** — não são thread-safe; use `TMonitor` ou `TCriticalSection`
