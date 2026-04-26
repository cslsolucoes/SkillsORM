---
name: developer-delphi-to-fpc-language-rtti
description: RTTI em Delphi — TRttiContext, TRttiProperty, TCustomAttribute, TValue e mapeamento JSON-objeto.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-language-rtti_V1.1.0

## Propósito

Dominar RTTI (Run-Time Type Information) em Delphi: TRttiContext, TRttiType, TRttiProperty, TRttiMethod, TCustomAttribute, TValue. Aplicações práticas: mapeamento JSON↔objeto, auto-binding de form fields, DI automático via attributes.

## Quando usar esta skill

- Inspecionar ou modificar propriedades de objetos em runtime
- Invocar métodos por nome (reflexão)
- Implementar custom attributes para metadados
- Construir mappers JSON/objeto genéricos
- Implementar DI (injeção de dependência) sem containers externos

## Conteúdo

### exemplos/

| Arquivo | Tema |
|---------|------|
| `rtti_basico.pas` | TRttiContext, GetType, TRttiType, enumerar props/methods |
| `rtti_propriedades.pas` | TRttiProperty: GetValue/SetValue com TValue |
| `rtti_metodos.pas` | TRttiMethod: Invoke com array of TValue |
| `attributes.pas` | TCustomAttribute: declarar, aplicar, ler com GetAttributes |
| `rtti_json_map.pas` | Mapeamento JSON↔objeto via RTTI + TJsonObject |
| `rtti_auto_bind.pas` | Auto-binding de form fields (TEdit) ↔ objeto via RTTI |

### consultas_rapidas/

| Arquivo | Tema |
|---------|------|
| `rtti_hierarquia.md` | TRttiObject → TRttiType → TRttiMember → props/methods |
| `tvalue_tipos.md` | TValue: AsType, FromOrdinal, AsObject; conversões seguras |
| `attributes_uso.md` | Declarar, aplicar e ler TCustomAttribute |
| `rtti_performance.md` | Custo de RTTI; cache de TRttiContext; quando evitar |

### templates/

| Arquivo | Uso |
|---------|-----|
| `TEMPLATE_attribute_custom.pas` | Attribute personalizado + leitura via RTTI |
| `TEMPLATE_rtti_mapper.pas` | Mapper objeto↔record via RTTI genérico |
| `TEMPLATE_auto_inject.pas` | DI automático via RTTI + attributes |

## Fontes

- `Doc-Delphi/delphi12-topics_chm_decompiled/` — "RTTI", "Attributes", "Reflection"
- `Doc-Delphi/delphi12-system_chm_decompiled/` — System.Rtti
- `Doc-Delphi/ObjectPascalHandbook_AlexandriaVersion.pdf` — Cap. RTTI
