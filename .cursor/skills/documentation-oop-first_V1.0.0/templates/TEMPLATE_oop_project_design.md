# Design OOP Inicial — {Nome do Projeto}

> **Artefato:** Design OOP Inicial
> **Data:** {dd/mm/aaaa}
> **Status:** Em elaboração | Revisão | Aprovado
> **Gerado por:** skill `documentation-oop-first_V1.0.0`

---

## Modulos Identificados

Liste os módulos de negócio do sistema. Cada linha = uma classe mestra.

| Módulo | Classe master | Interface | Responsabilidade |
| --- | --- | --- | --- |
| {Modulo1} | `T{Modulo1}` | `I{Modulo1}` | {Responsabilidade do módulo} |
| {Modulo2} | `T{Modulo2}` | `I{Modulo2}` | {Responsabilidade do módulo} |
| {Modulo3} | `T{Modulo3}` | `I{Modulo3}` | {Responsabilidade do módulo} |

---

## Hierarquia de Classes

```mermaid
classDiagram
    class I{Modulo1} {
        +{Metodo1}() tipo
        +{Metodo2}() tipo
    }
    class T{Modulo1} {
        -F{Campo1} tipo
        +New() I{Modulo1}
    }
    class T{Modulo1}{Subclasse1} {
        -F{CampoSub} tipo
        +New() I{Modulo1}{Subclasse1}
    }
    T{Modulo1} ..|> I{Modulo1}
    T{Modulo1}{Subclasse1} --> T{Modulo1}

    class I{Modulo2} {
        +{Metodo1}() tipo
    }
    class T{Modulo2} {
        +New() I{Modulo2}
    }
    T{Modulo2} ..|> I{Modulo2}
```

---

## Interfaces Publicas

Descreva o contrato de cada interface principal.

### `I{Modulo1}`

```pascal
I{Modulo1} = interface
  function {Metodo1}: tipo;
  function {Metodo2}: tipo;
  property {Campo}: tipo;
end;
```

**Responsabilidade:** {O que esta interface define}

### `I{Modulo2}`

```pascal
I{Modulo2} = interface
  function {Metodo1}: tipo;
  property {Campo}: tipo;
end;
```

**Responsabilidade:** {O que esta interface define}

---

## Submódulos por Módulo

| Módulo master | Submódulo | Classe | Tabela DB |
| --- | --- | --- | --- |
| `I{Modulo1}` | {Subclasse1} | `T{Modulo1}{Subclasse1}` | `{tabela_submodulo}` |
| `I{Modulo1}` | {Subclasse2} | `T{Modulo1}{Subclasse2}` | `{tabela_submodulo2}` |
| `I{Modulo2}` | {Subclasse1} | `T{Modulo2}{Subclasse1}` | `{tabela_submodulo}` |

---

## Proximos Passos

Após aprovação deste artefato:

1. `documentation-project-bootstrap_V2.1.0` — inicializar estrutura `Documentation/`
2. `documentation-project-fundamentals-template_V1.1.0` — documentar fundamentos com base neste design
3. `documentation-business-rules_V3.1.0` — formalizar regras de negócio referenciando as classes acima
4. `documentation-api-openapi_V1.1.0` — gerar spec OpenAPI com endpoints referenciando os serviços
5. Início da implementação Delphi conforme `developer-delphi-programming-oop-naming_V1.0.0`
