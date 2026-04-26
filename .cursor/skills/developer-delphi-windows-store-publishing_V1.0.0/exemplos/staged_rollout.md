# Staged Rollout — Lancamento Gradual na Microsoft Store

O staged rollout permite distribuir uma nova versao progressivamente para
uma porcentagem dos usuarios, monitorando estabilidade antes de atingir 100%.

> **AVISO:** A interface do Partner Center pode mudar. Validar em
> `partner.microsoft.com` antes de executar este guia.

---

## Por que usar Staged Rollout?

| Cenario | Beneficio |
|---------|-----------|
| Novo release com mudancas significativas | Detectar crashs antes de atingir todos |
| Update de banco de dados / migracoes | Validar compatibilidade antes de escalar |
| Mudancas em integracao com APIs externas | Monitorar falhas em producao real |
| Apps com grande base de usuarios | Reduzir impacto de bugs criticos |

---

## Parte 1 — Configurar Staged Rollout no Partner Center

### Passo 1.1 — Acessar configuracao de disponibilidade

**Caminho:**
```
Apps and games
  → [Seu app]
    → Submissions
      → [Submission atual]
        → Pricing and availability
          → Gradual package rollout
```

### Passo 1.2 — Habilitar rollout gradual

1. Marcar a opcao: **"Roll out update gradually after this submission is certified"**
2. Definir a porcentagem inicial:
   - **10%** para apps em producao com base grande de usuarios
   - **25%** para apps menores ou updates de baixo risco

### Passo 1.3 — Completar e submeter

- Preencher todos os outros campos da submission normalmente
- Clicar em **Submit to the Store**
- Aguardar certificacao (1-3 dias uteis)
- Apos aprovacao: o update e entregue para a porcentagem configurada

---

## Parte 2 — Progressao Recomendada

### Cronograma conservador (apps empresariais)

| Dia | Porcentagem | Acao |
|-----|------------|------|
| 0 | 10% | Submeter e aguardar certificacao |
| 1-2 | 10% | Monitorar crash rate e reviews |
| 3 | 25% | Se metricas OK, aumentar |
| 4-5 | 25% | Monitorar |
| 6 | 50% | Aumentar |
| 7-8 | 50% | Monitorar |
| 9 | 100% | Rollout completo |

### Cronograma rapido (updates de baixo risco / bugfixes)

| Dia | Porcentagem |
|-----|------------|
| 0 | 25% |
| 1 | 50% |
| 2 | 100% |

---

## Parte 3 — Como Alterar a Porcentagem

Apos a submission ser aprovada e o rollout iniciado:

**Caminho:**
```
Apps and games
  → [Seu app]
    → Submissions
      → [Submission aprovada]
        → Gradual rollout
          → Update percentage
```

- Inserir a nova porcentagem (deve ser maior que a atual)
- Salvar — a mudanca e aplicada em minutos

> **Atencao:** A porcentagem so pode ser aumentada, nunca diminuida.
> Para reverter, use "Stop rollout" (descrito na Parte 5).

---

## Parte 4 — Como Monitorar Metricas

### 4.1 — Crash rate e ANRs

**Caminho:**
```
Apps and games → [Seu app] → Health → Failures
```

| Metrica | Limiar de alerta | Acao recomendada |
|---------|-----------------|-----------------|
| Crash rate | > 2% | Pausar rollout; investigar |
| Crash rate | > 5% | Reverter imediatamente |
| Hang rate (ANR) | > 1% | Investigar antes de escalar |

### 4.2 — Reviews e ratings

**Caminho:**
```
Apps and games → [Seu app] → Reviews
```

Filtrar por "Recent" e ordenar por rating:
- Pico de reviews 1-2 estrelas apos update = sinal de problema
- Ler as reviews para identificar o issue especifico

### 4.3 — Relatorios de uso

**Caminho:**
```
Apps and games → [Seu app] → Insights → Acquisitions
```

- Monitorar se novos downloads caem apos update (indica problema de visibilidade)
- Verificar se usuarios que receberam o update desinstalam (churn)

### 4.4 — Feedback via Windows Error Reporting

O Partner Center recebe automaticamente os crash dumps dos usuarios afetados:
```
Apps and games → [Seu app] → Health → Failures → [Tipo de falha]
```
- Ver stack trace dos crashes
- Identificar a linha de codigo responsavel
- Baixar dump files para analise local com WinDbg

---

## Parte 5 — Como Reverter (Stop Rollout)

**QUANDO USAR:**
- Crash rate > 5% e crescendo
- Bug critico que impede uso basico do app
- Problema de seguranca identificado

**Caminho:**
```
Apps and games
  → [Seu app]
    → Submissions
      → [Submission aprovada]
        → Gradual rollout
          → Stop rollout
```

### O que acontece ao parar:

| Grupo de usuarios | Estado apos Stop |
|-------------------|-----------------|
| Usuarios que JA receberam o update | Continuam com a nova versao |
| Usuarios que NAO receberam o update | Ficam na versao anterior |
| Novos usuarios | Recebem a versao anterior |

> **IMPORTANTE:** "Stop rollout" NAO e um downgrade. Usuarios que ja
> receberam a versao nova NAO voltam para a versao anterior automaticamente.

### Para forcar rollback completo:

1. Publicar a versao anterior como nova submission com versao mais alta
   - Ex.: versao atual bugada = 1.2.0.0
   - Publicar versao estavel anterior = 1.2.1.0 (com o codigo da 1.1.0.0)
   - A versao deve ser MAIOR para a Store aceitar
2. Submeter sem staged rollout (rollout = 100%)

---

## Parte 6 — Boas Praticas

1. **Nunca pular o staged rollout** para releases com mudancas de schema de BD
2. **Monitorar ativamente** nas primeiras 24h apos cada aumento de porcentagem
3. **Configurar alertas** no Partner Center (se disponivel) para crash rate
4. **Documentar** cada stage com data e metricas observadas
5. **Comunicar** o time de suporte antes de escalar para 100%
6. **Ter um plano de rollback** documentado antes de submeter

---

## Resumo do Fluxo

```
[Submission] Habilitar staged rollout → 10%
        |
        v
[Certificacao] 1-3 dias uteis
        |
        v
[Monitorar] crash rate + reviews (24-48h)
        |
   OK? --+-- NÃO --> [Stop rollout] → corrigir → nova submission
        |
       SIM
        |
        v
[Aumentar] para 25% → monitorar → 50% → monitorar → 100%
        |
        v
[Rollout completo] todos os usuarios atualizados
```
