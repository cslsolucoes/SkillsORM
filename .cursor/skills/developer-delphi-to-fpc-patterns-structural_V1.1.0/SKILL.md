---
name: developer-delphi-to-fpc-patterns-structural
description: Padrões estruturais em Delphi — Composite, Decorator, Adapter, Proxy, Facade, Bridge via interface.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-patterns-structural_V1.1.0

## Propósito

Dominar padrões estruturais em Delphi: Composite, Decorator, Adapter, Proxy, Facade e Bridge. Foco em composição via interface — nunca herança profunda.

## Quando usar esta skill

- Compor hierarquias de objetos uniforme (Composite)
- Adicionar comportamento sem modificar a classe (Decorator)
- Integrar código legado com interface moderna (Adapter)
- Controlar acesso ou adicionar lazy-load (Proxy)
- Simplificar subsistema complexo (Facade)
- Desacoplar abstração de implementação (Bridge)

## Conteúdo

### exemplos/

| Arquivo | Tema |
|---------|------|
| `composite.pas` | Árvore de componentes UI: operações recursivas |
| `decorator.pas` | ILogger decorado: timestamp, prefix, async |
| `adapter.pas` | Adaptar ILegacyDB para IModernDB |
| `proxy.pas` | Proxy lazy-loading + proxy de cache |
| `facade.pas` | Facade para subsistema de relatórios |
| `bridge.pas` | Abstração (Shape) desacoplada de impl (Renderer) |

### consultas_rapidas/

| Arquivo | Tema |
|---------|------|
| `structural_quando.md` | Tabela: qual pattern para qual problema |
| `decorator_vs_proxy.md` | Decorator (comportamento) vs Proxy (acesso) |
| `composite_hierarquia.md` | Component/Leaf/Composite; recursão uniforme |

### templates/

| Arquivo | Uso |
|---------|-----|
| `TEMPLATE_decorator_chain.pas` | Cadeia de decorators com interface comum |
| `TEMPLATE_adapter_legacy.pas` | Adapter de código legado para interface moderna |

## Fontes

- `Doc-Delphi/ObjectPascalHandbook_AlexandriaVersion.pdf` — Cap. Patterns
- GoF — Design Patterns (Gamma et al.)
