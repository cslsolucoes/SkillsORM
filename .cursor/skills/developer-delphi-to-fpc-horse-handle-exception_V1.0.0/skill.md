---
name: developer-delphi-to-fpc-horse-handle-exception
description: Middleware HandleException do Horse para capturar exceções não tratadas e devolver respostas JSON de erro consistentes. Cobre HandleException (padrão e com callback custom), EHorseException fluente (Status, Error, Title) e mapeamento exception→HTTP. Fonte: app/package/docs/pacotes/handle-exception.md.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-horse-handle-exception

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Middleware para capturar exceções no pipeline Horse e converter em respostas HTTP JSON padronizadas.

## When to use

- Interceptar exceções não tratadas em handlers Horse
- Devolver erros HTTP (400, 401, 403, 404, 409, 500) como JSON
- Criar exceções HTTP com `EHorseException.New.Status().Error().Title()`
- Configurar interceptador custom de erros

## When NOT to use

- Log de exceções em disco → `developer-delphi-to-fpc-horse-exception-logger`
- JWT/Auth → `developer-delphi-to-fpc-horse-jwt` ou `developer-delphi-to-fpc-horse-basic-auth`

## Documento canônico

`app/package/docs/pacotes/handle-exception.md`

---

## Uso

```delphi
uses Horse, Horse.Jhonson, Horse.HandleException;

begin
  THorse
    .Use(Jhonson)          // ANTES do HandleException
    .Use(HandleException);
end;
```

**Ordem obrigatória:** `Jhonson` → `HandleException`

---

## HandleException — sobrecargas

| Sobrecarga | Descrição |
| --- | --- |
| `HandleException` | Middleware padrão (JSON automático) |
| `HandleException(callback)` | Com interceptador custom |

### Padrão

```delphi
THorse.Use(Jhonson).Use(HandleException);
```

### Com callback custom

```delphi
THorse.Use(HandleException(
  procedure(AException: Exception; ARequest: THorseRequest;
            AResponse: THorseResponse; var AHandled: Boolean)
  begin
    TMyLogger.Log(AException.Message);
    AResponse.Status(500);
    AResponse.Send('{"error":"' + AException.Message + '","timestamp":"' +
                   FormatDateTime('yyyy-mm-ddThh:nn:ss', Now) + '"}');
    AHandled := True;
  end
));
```

---

## EHorseException — exceção fluente

| Método | Descrição |
| --- | --- |
| `EHorseException.New` | Cria instância fluente |
| `.Status(code)` | Código HTTP (THTTPStatus ou Integer) |
| `.Error(msg)` | Mensagem de erro |
| `.Title(titulo)` | Campo `title` no JSON |

### Exemplos por código HTTP

```delphi
// 400 Bad Request
raise EHorseException.New
  .Status(THTTPStatus.BadRequest)
  .Error('Campo obrigatório em falta: email');

// 401 Unauthorized
raise EHorseException.New
  .Status(THTTPStatus.Unauthorized)
  .Error('Token expirado ou inválido');

// 403 Forbidden
raise EHorseException.New
  .Status(THTTPStatus.Forbidden)
  .Error('Sem permissão para esta operação');

// 404 Not Found
raise EHorseException.New
  .Status(THTTPStatus.NotFound)
  .Error('Utilizador não encontrado')
  .Title('Not Found');

// 409 Conflict
raise EHorseException.New
  .Status(THTTPStatus.Conflict)
  .Error('Email já registado neste sistema');

// 500 Internal Server Error (genérico)
raise EHorseException.New
  .Status(500)
  .Error('Erro interno do servidor');
```

### Em handler completo

```delphi
THorse.Post('/validate',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  begin
    if Req.Body = '' then
      raise EHorseException.New
        .Status(THTTPStatus.BadRequest)
        .Error('Corpo da requisição vazio');
    // processar...
    Res.Status(THTTPStatus.Created).Send('ok');
  end);
```

---

## Notas GestorERP

- Ordem de middlewares no DPR: `Jhonson` → `HandleException` → restantes
- Nunca deixar `Exception` nua chegar ao cliente — sempre encapsular em `EHorseException`
- Dependência: `jhonson` (resolvida via boss.json)

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill middleware handle-exception.
