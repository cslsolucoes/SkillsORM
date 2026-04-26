# Quando Usar Assembly — Criterios de Decisao

## Perguntas antes de escrever qualquer asm

1. **Voce mediu o problema?**
   - Use RDTSC ou profiler antes de qualquer otimizacao
   - Regra: nao otimize o que nao foi medido

2. **O compilador nao resolve automaticamente?**
   - Delphi com `{$O+}` pode vetorizar loops simples
   - Testar: compilar em Release e medir antes de asm

3. **A funcao esta no hot path real?**
   - Hot path = funcao chamada milhares de vezes por segundo
   - Uma funcao chamada 100x/s raramente justifica asm

## Tabela de criterios

| Situacao                                    | Assembly justificado? |
| ------------------------------------------- | --------------------- |
| Loop processando > 100k elementos/frame     | SIM — SIMD provavelmente vale|
| Funcao critica de hash/checksum em servidor | SIM — POPCNT, CRC32   |
| Manipulacao de bits de baixo nivel (flags)  | SIM — BSF, BSR, BT    |
| Leitura de registradores de CPU (RDTSC, CPUID)| SIM — unica forma   |
| Funcao chamada 1000x/s com calculo simples  | TALVEZ — medir primeiro|
| Funcao de configuracao/inicializacao        | NAO — performance irrelevante|
| Logica de negocio com if/else complexo      | NAO — asm muito dificil de manter|
| Funcao ja otimizada pelo compilador (-O3)   | NAO — overhead de complexidade|

## Ganhos tipicos de SIMD

| Operacao                    | Pascal puro | SSE (4x float) | AVX2 (8x float) |
| --------------------------- | ----------- | -------------- | ---------------- |
| Soma de array de 10M floats | 1x          | ~3-4x          | ~6-8x            |
| Produto escalar 1M elementos| 1x          | ~3x            | ~5x              |
| Copia de memoria (memcpy)   | 1x          | ~2x (RTL ja otimiza) | similar   |

*Ganhos reais variam com cache, alinhamento e CPU. Sempre medir.*

## Alternativas antes do asm

1. **Delphi RTL otimizada:** `Move`, `FillChar`, `CompareMem` ja usam SSE internamente
2. **IntrinsicsPascal:** Algumas operacoes tem equivalente Pascal otimizado
3. **Diretiva `{$O+}`:** Otimizador do compilador pode vetorizar automaticamente
4. **Bibliotecas especializadas:** MKL, OpenBLAS, IPP para algebra linear

## Custo de manutencao do asm

- Asm e ~5-10x mais dificil de ler/modificar que Pascal equivalente
- Bugs em asm sao muito mais dificeis de encontrar
- Cada mudanca de plataforma (Win32→Win64→Linux) pode exigir reescrita
- Calcule: ganho de performance * vida util do codigo > custo de manutencao?
