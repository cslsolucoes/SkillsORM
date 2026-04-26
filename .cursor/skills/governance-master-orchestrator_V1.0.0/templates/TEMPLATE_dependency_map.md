# TEMPLATE — Dependency Map

**Skill:** `governance-artifact-dependency-map_V1.0.0`
**Módulo / Escopo:** {nome do módulo ou feature}
**Data:** {YYYY-MM-DD}
**Autor:** {nome}

---

## 1. Dependências Diretas

```
{Módulo}
├── depende de → {Módulo A} (razão: {tipos compartilhados / interface / evento})
├── depende de → {Módulo B} (razão: {serviço de dados})
└── depende de → {Módulo C} (razão: {configuração})
```

---

## 2. Tabela de Dependências

| Módulo | Depende de | Tipo | Bidirecional? | Impacto se alterado |
|--------|-----------|------|:---:|-----|
| {Módulo} | {Módulo A} | {compilação / runtime / dados} | {sim / não} | {alto / médio / baixo} |
| {Módulo} | {Módulo B} | | | |

---

## 3. Dependências Externas

| Biblioteca / Serviço | Versão | Tipo de uso | Alternativa se indisponível |
|---------------------|--------|-------------|----------------------------|
| {biblioteca} | {vX.Y.Z} | {compilação / runtime} | {sim / não} |

---

## 4. Grafo de Impacto (Mudança em {Módulo Alvo})

```
{Módulo Alvo} [MUDANÇA]
  ↓ impacta
  {Módulo A}
    ↓ impacta
    {Módulo D}
  {Módulo B}
    ↓ impacta
    {Módulo E}
```

---

## 5. Módulos Isolados (sem dependências externas)

| Módulo | Observação |
|--------|-----------|
| {módulo} | {pode ser alterado de forma segura} |

---

## 6. Recomendações

- {Recomendação 1 — ex.: considerar inversão de dependência em X para reduzir acoplamento}
- {Recomendação 2}

---

**FileVersion:** 1.0.0 · **Skill:** `governance-artifact-dependency-map_V1.0.0`
