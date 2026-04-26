---
name: developer-delphi-to-fpc-language-oop
description: OOP em Delphi — classes, interfaces, herança, polimorfismo, encapsulamento e padrões de projeto.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-language-oop_V1.1.0

## O que é esta skill

Skill especializada em **OOP em Delphi**: classes, interfaces, herança, polimorfismo,
visibilidade, class methods, operator overloading e class helpers.

---

## Quando usar esta skill

- Declarar classe com constructor/destructor e gerenciar ciclo de vida
- Implementar herança: `virtual`, `override`, `abstract`, `final`
- Criar interfaces com GUID e implementar em `TInterfacedObject`
- Usar visibilidade: `private`, `strict private`, `protected`, `public`, `published`
- Sobrecarregar operadores em records/classes (`class operator Add`, `Equal`, etc.)
- Criar class helpers para estender tipos sem herança

---

## Referência rápida: visibilidade

| Modificador | Própria unit | Subclasse mesma unit | Subclasse outra unit | Fora |
|-------------|:---:|:---:|:---:|:---:|
| `private` | ✓ | ✓ | ✗ | ✗ |
| `strict private` | ✓ | ✗ | ✗ | ✗ |
| `protected` | ✓ | ✓ | ✓ | ✗ |
| `strict protected` | ✓ | ✗ | ✓ | ✗ |
| `public` | ✓ | ✓ | ✓ | ✓ |
| `published` | ✓ | ✓ | ✓ | ✓ + RTTI |

---

## Hierarquia fundamental

```
TObject
  ├─ TInterfacedObject  ← implementar interfaces com RefCount
  ├─ TAggregatedObject  ← aggregation pattern
  ├─ TPersistent        ← classe persistível
  │    └─ TComponent    ← com Name/Owner
  │         └─ ...
  └─ Exception          ← base de exceções
```

---

## Arquivos desta skill

| Arquivo | Conteúdo |
|---------|---------|
| `exemplos/classes_basicas.pas` | Declaração, constructor, destructor, properties |
| `exemplos/heranca_polimorfismo.pas` | virtual/override/abstract, dynamic dispatch |
| `exemplos/interfaces_impl.pas` | IInterface, TInterfacedObject, QueryInterface |
| `exemplos/interfaces_fluentes.pas` | Fluent interface com retorno Self |
| `exemplos/visibility.pas` | private/strict private/protected/public/published |
| `exemplos/class_methods.pas` | class method, class var, class property, Singleton |
| `exemplos/operadores.pas` | class operator Add/Equal/Implicit em record |
| `exemplos/helpers.pas` | class helper for string, record helper |
| `consultas_rapidas/visibilidade_tabela.md` | Tabela completa de visibilidade |
| `consultas_rapidas/interface_contagem.md` | Reference counting, ciclos, _AddRef/_Release |
| `consultas_rapidas/virtual_dynamic.md` | virtual (VMT) vs dynamic (DMT) |
| `consultas_rapidas/overload_override.md` | Diferença semântica overload/override |
| `templates/TEMPLATE_classe_base.pas` | Classe base com interface e factory method |
| `templates/TEMPLATE_interface_fluente.pas` | Builder fluente com interface |
| `templates/TEMPLATE_helper_string.pas` | String helper com métodos utilitários |

---

## Skills relacionadas

| Skill | Uso |
|-------|-----|
| `developer-delphi-to-fpc-language-types_V1.1.0` | Records, enums, arrays, tipos primitivos |
| `developer-delphi-to-fpc-language-core_V1.1.0` | Compilador, diretivas, módulos |
| `developer-delphi-to-fpc-patterns-composition_V1.1.0` | Design patterns Delphi |
