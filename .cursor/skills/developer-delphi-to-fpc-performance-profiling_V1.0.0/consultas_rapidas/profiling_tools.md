# Ferramentas de Profiling para Delphi

**Skill:** developer-delphi-to-fpc-performance-profiling_V1.0.0

---

## Comparativo de ferramentas

| Ferramenta | Tipo | Disponibilidade | Overhead | Melhor para |
|------------|------|----------------|----------|-------------|
| **AQTime** | Instrumentacao | Add-on RAD Studio (pago) | Alto | Call graph, alocacoes, cobertura |
| **Sampling Profiler** | Sampling | Integrado ao RAD Studio (IDE) | Baixo | Hotspot rapido sem recompilacao |
| **TStopwatch** | Manual | RTL (System.Diagnostics) | ~0 | Micro-benchmark de trecho especifico |
| **QueryPerformanceCounter** | Manual | Windows API | ~0 | Alta precisao fora do RTL |
| **GetTickCount64** | Manual | Windows API | ~0 | Timeouts e medicoes grosseiras |
| **Intel VTune** | Sampling | Standalone (gratuito) | Baixo | CPU microarchitecture, cache misses |
| **Very Sleepy** | Sampling | Open source | Baixo | Hotspot sem instalacao complexa |

---

## AQTime — Como usar

1. Instalar: **Tools > GetIt Package Manager > AQTime**.
2. Abrir o projeto no RAD Studio.
3. **Run > AQTime > Start Profiling** (ou Ctrl+Alt+F5).
4. Executar o caso de uso a medir.
5. Parar a aplicacao — AQTime exibe:
   - **Call Graph**: tempo por funcao e sub-chamadas.
   - **Allocation Profiler**: numero de objetos criados/destruidos por tipo.
   - **Performance Profiler**: tempo total, tempo proprio, numero de chamadas.

**Interpretar:**
- Coluna **Own Time %**: tempo gasto dentro da funcao, excluindo sub-chamadas.
- Coluna **Total Time %**: tempo incluindo todas as sub-chamadas.
- Foco em funcoes com Own Time % alto + Call Count alto = hotspot real.

---

## Sampling Profiler (IDE integrado)

1. Menu: **Run > Sampling Profiler**.
2. Executar a aplicacao normalmente.
3. Parar: clique em **Stop Sampling**.
4. Exibe lista de funcoes ordenadas por % de amostras.

**Vantagens:** sem recompilacao; overhead minimo (~1-3%).
**Limitacoes:** resolucao de ~1 ms; nao mostra alocacoes de memoria.

---

## TStopwatch — Referencia rapida

```pascal
uses System.Diagnostics;

var SW := TStopwatch.StartNew;
// ... codigo a medir ...
SW.Stop;

SW.ElapsedMilliseconds  // Int64 — ms
SW.ElapsedTicks         // Int64 — ticks de alta resolucao
TStopwatch.Frequency    // Int64 — ticks por segundo
```

Converter ticks para microsegundos:
```pascal
var Us := SW.ElapsedTicks / TStopwatch.Frequency * 1_000_000.0;
```

---

## QueryPerformanceCounter — Alta resolucao (Windows API)

```pascal
uses Winapi.Windows;

var Freq, T1, T2: Int64;
QueryPerformanceFrequency(Freq);
QueryPerformanceCounter(T1);
// ... codigo a medir ...
QueryPerformanceCounter(T2);
var ElapsedUs := (T2 - T1) / Freq * 1_000_000.0;
```

`TStopwatch` usa internamente `QueryPerformanceCounter` quando disponivel — prefira `TStopwatch` por ser mais idiomatico em Delphi.

---

## GetTickCount64 — Medicao grosseira

```pascal
uses Winapi.Windows;

var T1 := GetTickCount64;
// ... operacao longa ...
var Elapsed := GetTickCount64 - T1; // em milissegundos (~15 ms de resolucao)
```

Usar apenas para timeouts e operacoes com duracao esperada > 100 ms.

---

## Intel VTune (opcional)

- Download gratuito: https://www.intel.com/content/www/us/en/developer/tools/oneapi/vtune-profiler.html
- Modo: **Hotspots Analysis** → mostra funcoes que mais consomem CPU.
- Nao requer recompilacao; funciona com qualquer executavel Windows.
- Util para identificar cache misses e instrucoes de hardware criticas.
