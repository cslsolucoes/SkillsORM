# Armadilhas de Paralelismo — Race Conditions, Deadlocks, False Sharing

## 1. Race Condition — acesso concorrente não protegido

### Sintoma
Resultado diferente a cada execução; crashes intermitentes; valores truncados ou inválidos.

### Exemplo e correção

```pascal
// ERRADO — várias threads incrementam Total simultaneamente (race condition)
var Total: Integer := 0;
TParallel.For(0, N - 1, procedure(I: Integer)
begin
  Inc(Total);   // leitura-modificação-escrita NÃO é atômica em Pascal
end);
// Total pode ser < N ao final

// CORRETO opção A — TInterlocked (lock-free, mais rápido)
TParallel.For(0, N - 1, procedure(I: Integer)
begin
  TInterlocked.Increment(Total);
end);

// CORRETO opção B — TCriticalSection (mais lento, mas suporta operações complexas)
var Lock := TCriticalSection.Create;
TParallel.For(0, N - 1, procedure(I: Integer)
begin
  Lock.Enter;
  try Inc(Total);
  finally Lock.Leave; end;
end);
Lock.Free;
```

### Detecção
- Habilitar Thread Sanitizer (se disponível no compilador)
- Testar com `N >> número de CPUs` para aumentar probabilidade de colisão
- Resultados não-determinísticos entre execuções = forte indício de race condition

---

## 2. Deadlock — threads bloqueadas mutuamente

### Cenário clássico: locks em ordem invertida

```
Thread A: adquire Lock1 → tenta Lock2 (bloqueada: B tem Lock2)
Thread B: adquire Lock2 → tenta Lock1 (bloqueada: A tem Lock1)
→ DEADLOCK: nenhuma avança
```

```pascal
// ERRADO — Thread A e B adquirem locks em ordem diferente
procedure ThreadA;
begin
  Lock1.Enter; try Lock2.Enter; try ... finally Lock2.Leave; end; finally Lock1.Leave; end;
end;
procedure ThreadB;
begin
  Lock2.Enter; try Lock1.Enter; try ... finally Lock1.Leave; end; finally Lock2.Leave; end;
  // ^ Inverte a ordem → deadlock potencial
end;

// CORRETO — ordem canônica global: sempre Lock1 antes de Lock2
procedure ThreadB_Correto;
begin
  Lock1.Enter; try Lock2.Enter; try ... finally Lock2.Leave; end; finally Lock1.Leave; end;
end;
```

### Cenário: Synchronize + WaitFor

```pascal
// ERRADO
var W := TWorkerThread.Create;
W.WaitFor;    // main thread bloqueia
// W chama Synchronize → espera main thread → deadlock

// CORRETO: usar Queue em vez de Synchronize, ou WaitFor em background
var W := TWorkerThread.Create;
W.Start;
// Worker usa Queue (não Synchronize) para UI
// Aguardar em outro lugar (ex.: OnClose do Form)
```

### Regras de prevenção de deadlock

| Regra | Descrição |
|---|---|
| Ordem canônica | Todos adquirem locks na mesma ordem global |
| Timeout em TryEnter | Usar `TryEnter(timeout)` em vez de `Enter` + detectar falha |
| Hierarquia de locks | Lock de nível N só pode ser adquirido com locks de nível < N |
| Evitar Synchronize com WaitFor | Usar Queue ou aguardar em thread separada |
| Minimizar locks aninhados | Nunca adquirir Lock B enquanto segura Lock A se não necessário |

---

## 3. False Sharing — cache line contention

### O problema

Múltiplas threads escrevem em variáveis **diferentes** que ficam na mesma cache line (64 bytes). O hardware invalida a linha inteira quando qualquer thread escreve, causando contenção desnecessária.

```pascal
// PROBLEMA: array de inteiros adjacentes — todos na mesma cache line
var Contadores: array[0..3] of Integer;   // 4 × 4 = 16 bytes → 1 cache line

TParallel.For(0, 3, procedure(I: Integer)
begin
  for var J := 0 to 100000 do
    Inc(Contadores[I]);  // thread 0 invalida cache de thread 1, 2, 3
end);
```

```pascal
// SOLUÇÃO A: acumular localmente, gravar ao final (preferida)
TParallel.For(0, 3, procedure(I: Integer)
var Local: Integer;
begin
  Local := 0;
  for var J := 0 to 100000 do Inc(Local);
  TInterlocked.Add(TotalGlobal, Local);   // 1 operação atômica ao final
end);

// SOLUÇÃO B: padding para separar em cache lines diferentes
type
  TContadorPadded = record
    Valor  : Integer;
    Padding: array[0..59] of Byte;  // 60 bytes de padding → 64 bytes total
  end;
var ContadoresPadded: array[0..3] of TContadorPadded;
```

---

## 4. Load Imbalance — threads com cargas desiguais

### Sintoma
Algumas threads terminam muito antes de outras; CPUs ociosas enquanto 1-2 trabalham.

```pascal
// PROBLEMA: TParallel.For com itens de custo variável
TParallel.For(0, N - 1, procedure(I: Integer)
begin
  // Itens pares: rápidos (1 ms)
  // Itens ímpares: lentos (100 ms)
  // A última thread ímpar determina o tempo total
  ProcessarItem(Dados[I]);
end);

// SOLUÇÃO: usar TThreadedQueue para distribuição dinâmica
// Threads consomem da fila conforme ficam livres
var Q := TThreadedQueue<Integer>.Create(N, INFINITE, 500);
// Produtor enfileira todos os índices
// N threads consumidoras pegam próximo disponível → distribuição automática
```

---

## 5. ABA Problem em CAS (CompareExchange)

### O problema

```
Thread A: lê Ptr = X
Thread B: muda Ptr X → Y → X (de volta para X)
Thread A: CAS verifica Ptr = X (correto!), faz troca — mas estado mudou!
```

Em Delphi, `TInterlocked.CompareExchange` com ponteiros pode sofrer ABA para
estruturas de dados complexas (listas encadeadas lock-free).

**Mitigação:** Para contadores simples e flags, ABA não é um problema. Para
estruturas de dados lock-free complexas, use um contador de versão junto com o ponteiro.

---

## 6. Starvation — thread nunca executa

### Causas comuns

```pascal
// CAUSA A: prioridade muito baixa
W.Priority := tpIdle;  // pode nunca rodar se sistema estiver ocupado

// CAUSA B: lock seguro por thread de alta prioridade
// Thread de alta prioridade segura Lock → thread de baixa nunca adquire
// → Priority Inversion

// CAUSA C: TThreadedQueue com capacidade cheia e muitos produtores
// Consumidor lento → produtores bloqueam em PushItem → starvation de produtores
```

**Mitigação:** Balancear prioridades; usar timeout em TryEnter; dimensionar filas adequadamente.

---

## 7. Overhead de context switch

### Quando ocorre
Ao usar muitas threads com locks curtos, o overhead de context switch supera o ganho de paralelismo.

```pascal
// MAL USO: 1000 tasks para N = 1000 itens de 1 ms cada
// Overhead de criação + context switch > ganho
for I := 0 to 999 do
  TTask.Run(procedure begin ProcessarItem(I); end);  // 1000 tasks desnecessárias

// CORRETO: granularidade adequada — 1 task por CPU
var NCPUs := TThread.ProcessorCount;
// Dividir em NCPUs chunks, 1 TTask por chunk
```

---

## Checklist de revisão de código paralelo

- [ ] Toda variável compartilhada modificada em threads tem lock ou TInterlocked
- [ ] Locks aninhados adquiridos em ordem canônica global
- [ ] Nenhum Synchronize dentro de contexto com WaitFor ativo na main thread
- [ ] TParallel.For não contém I/O bloqueante
- [ ] Acumuladores por thread locais antes de combinar (evita false sharing)
- [ ] Closures de loop capturam variáveis locais (não a variável de iteração)
- [ ] Exceções de TTask verificadas via .Status ou capturadas em WaitForAll
- [ ] Granularidade de tasks adequada (não criar 1 task por elemento pequeno)

---

## Referências cruzadas

- `tinterlocked_api.md` — referência rápida de operações atômicas
- `exemplos/lock_free.pas` — CAS e lazy init
- `exemplos/parallel_aggregate.pas` — acumuladores locais
- `developer-delphi-to-fpc-threading-basics_V1.1.0/consultas_rapidas/thread_safety_regras.md`
