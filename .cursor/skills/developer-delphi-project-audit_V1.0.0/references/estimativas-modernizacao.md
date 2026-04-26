# Guia de Estimativa de Esforço para Modernização Delphi

## Metodologia de Estimativa

Use os multiplicadores abaixo baseado no tamanho do sistema:

| Porte do Sistema | Forms | Units | Linhas de Código |
|-----------------|-------|-------|-----------------|
| Pequeno | < 20 | < 50 | < 10.000 |
| Médio | 20–80 | 50–200 | 10.000–50.000 |
| Grande | 80–200 | 200–500 | 50.000–200.000 |
| Enterprise | > 200 | > 500 | > 200.000 |

---

## Atividades e Estimativas Base (sistema médio)

### Migração de BDE para FireDAC
| Subtarefa | Esforço (dias) |
|-----------|---------------|
| Mapeamento de todas conexões BDE | 2–3 |
| Substituição de TTable por TFDTable | 3–5 por DataModule |
| Substituição de TQuery por TFDQuery | 2–3 por DataModule |
| Ajuste de SQL incompatíveis | 1–2 por unit |
| Testes de regressão | 5–10 |
| **Total sistema médio** | **20–40 dias** |

> Fator de risco: +50% se o sistema usar campos BLOB ou stored procedures específicas do Paradox/dBase

### Migração de ADO para FireDAC
| Subtarefa | Esforço (dias) |
|-----------|---------------|
| Mapeamento de conexões ADO | 1–2 |
| Substituição de TADOQuery | 1–2 por DataModule |
| Teste de compatibilidade SQL | 3–5 |
| **Total sistema médio** | **10–20 dias** |

### Extração de Regras de Negócio (Forms → Classes)
| Subtarefa | Esforço (dias) |
|-----------|---------------|
| Análise e mapeamento de regras por Form | 1–2 por Form |
| Criação de classes de domínio | 2–3 por módulo |
| Refatoração dos Forms | 1–2 por Form |
| Testes unitários básicos | 3–5 |
| **Total sistema médio (30 forms)** | **60–120 dias** |

> Esta é tipicamente a atividade de maior esforço numa modernização

### Atualização de Versão do Delphi
| De → Para | Esforço (dias) |
|-----------|---------------|
| Delphi 7 → Delphi 10.4+ | 15–40 |
| Delphi 2007/2009 → Delphi 11/12 | 10–25 |
| Delphi XE → Delphi 12 | 5–15 |
| Delphi 10.x → Delphi 12 | 2–8 |

> Principais fontes de esforço na migração de versão:
> - Componentes de terceiros sem versão atualizada
> - Strings AnsiString → UnicodeString (Delphi < 2009)
> - Uso de typecasts inseguros
> - Diretivas de compilação específicas de versão

### Implementação de Segurança
| Subtarefa | Esforço (dias) |
|-----------|---------------|
| Autenticação com hash de senha (bcrypt/SHA-256) | 3–5 |
| Sistema de perfis/permissões | 5–10 |
| Log de auditoria centralizado | 3–5 |
| Criptografia de configurações | 2–3 |
| **Total** | **13–23 dias** |

### Documentação Técnica
| Subtarefa | Esforço (dias) |
|-----------|---------------|
| Documentação de units/procedures | 0.5 dia por 500 linhas |
| Manual do desenvolvedor | 3–5 |
| Diagrama de arquitetura | 2–3 |
| **Total sistema médio** | **10–20 dias** |

---

## Fórmula de Estimativa Consolidada

```
Esforço Total = Soma das atividades × Fator de Porte × Fator de Risco

Fator de Porte:
  Pequeno   = 0.5x
  Médio     = 1.0x  (base)
  Grande    = 2.5x
  Enterprise = 5.0x+

Fator de Risco (acumule os aplicáveis):
  Sem documentação existente      = +20%
  Alta rotatividade da equipe     = +15%
  Ausência de ambiente de testes  = +25%
  Componentes sem suporte         = +20%
  Banco de dados legado (Access)  = +30%
  Integração com sistemas externos = +15% por integração
```

---

## Exemplos de Estimativa

### Exemplo 1: Sistema Financeiro Pequeno (BDE + Delphi 7)
```
Atividades:
  Migração BDE → FireDAC:              15 dias
  Atualização Delphi 7 → 12:           25 dias
  Extração de regras (10 forms):       25 dias
  Implementação de segurança:          15 dias
  Documentação:                         8 dias
                              Subtotal: 88 dias

Fator de Porte (Pequeno):              × 0.5 = 44 dias
Fatores de Risco (sem docs + sem testes): +45% = ~64 dias

Estimativa Final: ~3 meses com equipe de 1 dev sênior
```

### Exemplo 2: ERP Médio (ADO + Delphi 2009)
```
Atividades:
  Migração ADO → FireDAC:              15 dias
  Atualização Delphi 2009 → 12:        20 dias
  Extração de regras (40 forms):       80 dias
  Implementação de segurança:          20 dias
  Documentação:                        15 dias
                              Subtotal: 150 dias

Fator de Porte (Médio):                × 1.0 = 150 dias
Fatores de Risco (componentes + integrações): +35% = ~200 dias

Estimativa Final: ~10 meses com 1 dev sênior
                  ou ~5 meses com 2 devs sênior
```

---

## Recomendações para Apresentação da Estimativa

1. **Sempre apresente uma faixa** (mínimo–máximo), nunca um número fixo
2. **Detalhe as premissas** (equipe, dedicação, acesso ao ambiente)
3. **Indique o que NÃO está incluído** (treinamento, infraestrutura, dados)
4. **Sugira validação** de estimativa após análise mais detalhada (fase de discovery)
5. **Faseie a entrega** para reduzir risco e gerar valor incremental
