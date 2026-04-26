# Decorator vs. Proxy — diferenças essenciais

## Intenção

| | Decorator | Proxy |
|-|-----------|-------|
| **Objetivo** | Adicionar comportamento | Controlar acesso |
| **Conhece o real?** | Não precisa conhecê-lo em criação | Proxy cria/gerencia o real |
| **Transparência** | Empilhável — N decoradores | Geralmente uma camada |
| **Quando o real existe?** | Já existe (passado no ctor) | Proxy pode criar lazy |

---

## Decorator — adicionar comportamento

```pascal
// Interface comum — Decorator E real implementam a mesma
type ILogger = interface
  procedure Log(const AMsg: string);
end;

// Decorator adiciona comportamento ANTES ou DEPOIS
type TTimestampLogger = class(TLoggerDecorator)
  procedure Log(const AMsg: string); override;
  // Chama FInner.Log(prefixo + AMsg) — o real é passado de fora
end;

// Empilhamento
var L: ILogger := TFilterLogger.Create(
  TTimestampLogger.Create(
    TConsoleLogger.Create));
```

**Características:**
- Decoradores são intercambiáveis: qualquer ordem é válida
- O componente real é injetado externamente — Decorator não cria o real
- Cada decorator adiciona UMA responsabilidade

---

## Proxy — controlar acesso

```pascal
// O cliente não sabe se está falando com o real ou com um proxy
type TRelatorioLazyProxy = class(TInterfacedObject, IRelatorioService)
private
  FReal: IRelatorioService;  // ← nil até EnsureReal
  procedure EnsureReal;
public
  function Gerar(const AId: string): string;
  // Proxy CRIA o real quando necessário — não recebe de fora
end;
```

**Características:**
- Proxy controla o ciclo de vida do objeto real (lazy creation, cache TTL)
- Proxy de proteção pode REJEITAR chamadas (AccessViolation)
- Proxy de cache decide quando chamar o real ou não

---

## Quando confundir é um problema

```pascal
// Errado: usar Proxy quando quer empilhar comportamento
// Um proxy de "timestamp + filtro + cache" fica monolítico e não reutilizável.
// Correto: usar Decorator para comportamento, Proxy para intermediação de acesso.

// Composição correta: Proxy de cache wrapping o serviço real,
// e um Decorator de log wrapping o proxy
var S: IRelatorioService :=
  TLogDecorator.Create(             // Decorator: adiciona log
    TRelatoriosCacheProxy.Create(   // Proxy: adiciona cache
      TRelatorioServiceReal.Create)); // Real
```

---

## Resumo prático

| Pergunta | Resposta |
|----------|----------|
| Quero adicionar prefix/suffix/timing ao método? | Decorator |
| Quero que o objeto real só exista quando necessário? | Proxy (lazy) |
| Quero impedir chamadas não autorizadas? | Proxy (protection) |
| Quero armazenar resultado e retornar sem chamar o real? | Proxy (cache) |
| Quero combinar várias adições de comportamento? | Decorator em cadeia |
| Quero representar objeto remoto localmente? | Proxy (remote) |
