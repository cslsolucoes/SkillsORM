# Como Identificar e Ler um CPU Profile em Delphi

**Skill:** developer-delphi-to-fpc-performance-profiling_V1.0.0

---

## Regra dos 80/20 para profiling

Em aplicacoes tipicas, **80% do tempo de CPU e gasto em 20% do codigo**.
Concentre a otimizacao nesses hotspots; nao otimize codigo frio.

**Criterio pratico:** otimizar apenas funcoes com `Own Time % >= 10%` do total.

---

## Lendo o Sampling Profiler do RAD Studio

Apos parar a coleta, a lista mostra:

| Coluna | Significado |
|--------|-------------|
| **Function** | Nome da funcao / metodo |
| **Samples** | Numero de vezes que a funcao apareceu nas amostras |
| **%** | Percentual do tempo total de CPU |
| **Module** | DLL ou EXE onde a funcao reside |

**Interpretacao:**
1. Ordenar por `%` decrescente.
2. As 3-5 primeiras linhas sao os hotspots candidates.
3. Verificar se pertencem ao seu codigo (e nao ao RTL ou OS).
4. Confirmar com TStopwatch antes de otimizar.

---

## Lendo o AQTime — Performance Profiler

Colunas mais importantes na visao **Routine Details**:

| Coluna | Significado |
|--------|-------------|
| **Own Time** | Tempo dentro da funcao, SEM sub-chamadas |
| **Total Time** | Tempo incluindo TODAS as sub-chamadas |
| **Call Count** | Quantas vezes a funcao foi chamada |
| **Own Time %** | % de Own Time sobre total do perfil |

**Algoritmo de decisao:**

```
SE Own Time % >= 10%:
  → hotspot real — otimizar a funcao em si
SE Total Time % alto mas Own Time % baixo:
  → a funcao chama outra funcao lenta — descer no call graph
SE Call Count muito alto com Own Time baixo:
  → overhead de chamada — considerar inlining ou cache de resultado
```

---

## Padroes comuns de hotspot

| Sintoma | Causa provavel | Solucao |
|---------|---------------|---------|
| `TStringList.IndexOf` com Call Count alto | Busca linear O(n) em lista grande | Substituir por `TDictionary<string,T>` |
| `TObject.Create/Destroy` dominando perfil | Criacao/destruicao frequente em loop | Pool de objetos ou reutilizacao |
| String concatenation (`+`) em loop | O(n^2) de realocacao | `TStringBuilder` ou array + Join |
| Query SQL executada N vezes | N+1 query problem | Batch ou cache de resultado |
| `Format()` ou `IntToStr()` em loop critico | Overhead de conversao | Pre-calcular ou usar LookupTable |
| `TFileStream.Read` por byte | I/O sem buffer | `TBufferedFileStream` ou `TBytesStream` |

---

## Validar hotspot com TStopwatch

Antes de otimizar, confirmar que o trecho identificado pelo profiler realmente
representa o gargalo:

```pascal
// Passo 1: isolar o trecho suspeito
var SW := TStopwatch.StartNew;
for I := 1 to 10000 do
  TrechoSuspeito(Dados[I]);
SW.Stop;
WriteLn('Trecho suspeito: ' + IntToStr(SW.ElapsedMilliseconds) + ' ms');

// Passo 2: medir o total da operacao externa
SW := TStopwatch.StartNew;
OperacaoCompleta;
SW.Stop;
WriteLn('Total: ' + IntToStr(SW.ElapsedMilliseconds) + ' ms');

// Se trecho_suspeito/total >= 20%: confirmar como hotspot real
```

---

## Checklist antes de otimizar

- [ ] Baseline registrado (ms ou us antes da mudanca)
- [ ] Hotspot confirmado por profiler E por TStopwatch
- [ ] Own Time % >= 10% do total do perfil
- [ ] Build Release usado para medicao (nao Debug)
- [ ] Aquecimento de cache executado antes das medicoes
- [ ] Testes unitarios existentes para o trecho a otimizar
- [ ] Resultado apos otimizacao documentado (speedup %)
