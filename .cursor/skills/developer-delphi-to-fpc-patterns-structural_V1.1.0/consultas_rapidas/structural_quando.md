# Padrões Estruturais — quando usar cada um

## Tabela de decisão rápida

| Problema | Pattern | Pergunta-chave |
|----------|---------|----------------|
| Tratar objetos individuais e coleções de forma uniforme | **Composite** | "Preciso operar sobre um e vários da mesma forma?" |
| Adicionar comportamento sem alterar a classe | **Decorator** | "Quero empilhar responsabilidades dinamicamente?" |
| Integrar API legada com interface moderna | **Adapter** | "Tenho incompatibilidade de interface que não posso alterar?" |
| Controlar acesso, adicionar cache ou lazy load | **Proxy** | "Preciso de intermediação transparente?" |
| Simplificar subsistema complexo | **Facade** | "O cliente não deveria precisar conhecer os detalhes?" |
| Desacoplar abstração de implementação | **Bridge** | "Preciso variar abstração E implementação independentemente?" |

---

## Composite

**Use quando:** hierarquias de parte-todo (UI, menu, sistema de arquivos, expressões).

```
IUIComponent           ← interface comum
  TUILabel (Leaf)      ← sem filhos
  TUIButton (Leaf)     ← sem filhos
  TUIPanel (Composite) ← tem filhos: TList<IUIComponent>
```

Sinal de uso: operações recursivas (Render, Calcular, SetVisible) aplicadas uniformemente a folhas e compostos.

---

## Decorator

**Use quando:** comportamentos opcionais combináveis (log + timestamp + filtro + async).

```
ILogger ← interface base
TConsoleLogger     (componente base)
TLoggerDecorator   (base abstrata — wraps ILogger)
  TTimestampLogger
  TLevelLogger
  TFilterLogger
```

Diferença de herança: N decoradores = N classes; herança geraria 2^N subclasses para N comportamentos.

---

## Adapter

**Use quando:** integrar código legado ou biblioteca de terceiros com interface nova.

```
IModernDB   ← interface que o código novo usa
ILegacyDB   ← interface que não pode alterar
TAdapter    ← implements IModernDB, wraps ILegacyDB
```

Não confundir com Facade: Adapter converte interface; Facade simplifica subsistema.

---

## Proxy

**Use quando:** acesso transparente com comportamento adicional.

| Tipo de Proxy | Uso |
|---------------|-----|
| Lazy Loading | Criar objeto caro só quando necessário |
| Cache | Memorizar resultados de operações custosas |
| Protection | Controle de acesso sem alterar o real |
| Remote | Representar objeto em outro processo/host |
| Virtual | Placeholder até o real estar disponível |

---

## Facade

**Use quando:** subsistema tem muitas classes interdependentes e o cliente só precisa de um fluxo principal.

```
Cliente → TRelatorioFacade.GerarRelatorio(opts)
  ↓ internamente orquestra:
  TDataAccessLayer.ConsultarDados
  TRelatorioFormatter.FormatarHTML
  TExportEngine.SalvarArquivo
  TAuditLogger.RegistrarGeracao
```

---

## Bridge

**Use quando:** abstração e implementação devem evoluir independentemente.

```
// Sem Bridge: M abstrações × N implementações = M×N classes
// Com Bridge: M abstrações + N implementações = M+N classes

TShape ──────────── IRenderer
  TCirculo            TConsoleRenderer
  TRetangulo          TSVG_Renderer
  TLinha              TOpenGLRenderer
```

Sinal de uso: você tem duas dimensões de variação (o QUÊ e o COMO).
