# Regras de Modularização Delphi

**Skill:** `developer-delphi-to-fpc-architecture-modules_V1.0.0`
**Data:** 2026-04-11

---

## Princípios fundamentais

| Regra | Descrição |
|-------|-----------|
| **Interface pública separada** | Cada módulo expõe sua API em `*.Interfaces.pas`; consumidores dependem apenas dessa unit |
| **Implementação privada** | Código concreto em `*.Impl.pas`; não referenciado diretamente por outros módulos |
| **Factory pública** | Único ponto de criação: `TXxxFactory.New(...)` retorna interface |
| **Sem dependências circulares** | Nenhum par de modules (A,B) onde A usa B e B usa A na interface section |
| **Alta coesão** | Uma unit = uma responsabilidade; evitar "God Unit" com múltiplos domínios |
| **Baixo acoplamento** | Dependências entre módulos exclusivamente via interfaces (`I*`) |

---

## Estrutura de módulo canônica

```
src/Modulos/Clientes/
  GestorERP.Clientes.Interfaces.pas   ← interface pública (IClienteRepository, etc.)
  GestorERP.Clientes.Impl.pas         ← implementação interna (TClienteImpl)
  GestorERP.Clientes.Factory.pas      ← factory: TClienteFactory.New
  GestorERP.Clientes.Repository.SQLite.pas  ← impl específica de banco
  GestorERP.Clientes.Repository.Memory.pas  ← impl para testes
```

**Regra de dependências entre módulos:**
```
Clientes.Factory  →  Clientes.Interfaces  ← Pedidos.Impl
Clientes.Impl     →  Clientes.Interfaces
Pedidos.Impl      →  Clientes.Interfaces  (não Clientes.Impl!)
```

---

## Dependências circulares — detecção e solução

### Sintoma
Erro de compilação:
```
[dcc32 Error] uCliente.pas: E2047 Circular unit reference to uPedido
```

### Diagrama do problema
```
uCliente (interface section) → uses uPedido
uPedido  (interface section) → uses uCliente   ← CIRCULAR
```

### Soluções (em ordem de preferência)

**1. Tipo compartilhado em unit base (melhor)**
```pascal
// uCommon.Types.pas — sem dependências
type TClienteID = type Integer;
// uCliente usa uCommon.Types → sem cycle
// uPedido  usa uCommon.Types → sem cycle
```

**2. Interfaces para desacoplar**
```pascal
// uCliente.Interfaces.pas define ICliente
// uPedido.Impl.pas usa uCliente.Interfaces (não uCliente.Impl!)
// → sem circular
```

**3. `uses` na implementation section**
```pascal
unit uCliente;
interface
  // SEM uses uPedido aqui
  type TCliente = class ... end;
implementation
  uses uPedido;   // ← compila; mas tipos de uPedido não aparecem na interface
```

**4. Forward declaration**
```pascal
// Dentro da mesma unit (quando os tipos estão na mesma unit)
type
  TPedido = class;   // forward
  TCliente = class
    FPedidos: TList; // não precisa saber o corpo de TPedido ainda
  end;
  TPedido = class    // definição completa
    FCliente: TCliente;
  end;
```

---

## Packages BPL — quando usar

| Cenário | Recomendação |
|---------|-------------|
| App standalone simples | Link estático (sem runtime packages) — zero dependência de BPL |
| Suite de apps que compartilham código | Runtime packages — .bpl compartilhado em PATH |
| Sistema de plugins extensível | BPL ou DLL carregados dinamicamente |
| Componentes visuais para o IDE | Design-time package obrigatório |
| App embarcado / single-file deploy | Link estático — sem BPLs distribuídas |

---

## Checklist antes de criar uma nova unit

- [ ] Qual é a única responsabilidade desta unit? (se houver mais de uma → dividir)
- [ ] Quais units ela vai referenciar em `interface`? (verificar ciclos)
- [ ] Pode usar a interface de outro módulo em vez da implementação?
- [ ] Existe uma unit base onde tipos compartilhados deveriam morar?
- [ ] O nome segue a convenção `Empresa.Produto.Modulo.Responsabilidade`?

---

## Anti-padrões de modularização

| Anti-padrão | Consequência | Solução |
|-------------|-------------|---------|
| `uses` de implementação concreta entre módulos | Acoplamento rígido; impossível substituir | Usar interface `I*` |
| Tipos compartilhados em um dos módulos dependentes | Causa circular reference | Mover para unit base |
| Package de runtime sem controle de versão no nome | Conflito de versões em deploy | `MeuPkg_2_1.bpl` |
| Interface pública com tipos internos de implementação | Vaza detalhes internos; dificulta mudanças | Usar apenas tipos das interfaces públicas |
| Unit com mais de 3 responsabilidades distintas | Difícil de testar e manter | SRP: uma unit = uma responsabilidade |
