# Checklist OOP Before Docs — documentation-oop-first

Use antes de escrever qualquer documentação de feature, RN ou endpoint para um projeto **sem código-fonte existente**.

## Checklist — Design OOP obrigatório antes de documentar

### Passo 1 — Módulos identificados

- [ ] Listei todos os domínios de negócio do sistema
- [ ] Cada domínio tem um nome de módulo master (`TModulo`)
- [ ] Nenhum módulo está duplicado ou sobrepostos com outro

### Passo 2 — Interfaces definidas

- [ ] Para cada módulo master, existe uma interface `IModulo` com os métodos públicos
- [ ] As interfaces definem **o que** o módulo faz — não como implementa
- [ ] Nenhuma implementação foi escrita antes das interfaces

### Passo 3 — Submódulos mapeados

- [ ] Identifiquei entidades relacionadas para cada módulo master
- [ ] Cada entidade relacionada tem nome `TModuloSubclasse` (ex.: `TClienteEndereco`)
- [ ] Submódulos com contrato externo têm `IModuloSubclasse`

### Passo 4 — Diagrama criado

- [ ] Existe um diagrama Mermaid `classDiagram` ou equivalente ASCII com a hierarquia
- [ ] O diagrama mostra módulos master, submódulos e suas relações
- [ ] O diagrama está no artefato "Design OOP Inicial" (ver `templates/TEMPLATE_oop_project_design.md`)

### Passo 5 — Pronto para documentar

- [ ] Todos os 4 passos acima estão completos
- [ ] Posso referenciar a classe responsável em cada feature que vou documentar
- [ ] Só agora inicio: features, regras de negócio (RN) e endpoints REST

## Resultado esperado

Todos os itens marcados = pode iniciar documentação com `documentation-project-bootstrap_V2.1.0` e depois `documentation-business-rules_V3.1.0`.

Se algum item falhar, volte ao passo correspondente antes de prosseguir.
