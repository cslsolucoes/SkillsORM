---
description: "Exemplos de autenticação REST — JWT, Basic, AccessTag, OAuth2"
alwaysApply: false
---

# Roteiro — Autenticação REST (REST DataWare)

> Fonte canônica: `app/modules/REST-DataWare/Documentation/Analise/Mechanics/RESTDWAuthenticators.md`

## 1. Basic Auth — configuração no servidor

```pascal
uses uRESTDWPoolerDB;

// No servidor: configurar modo de autenticação Basic
procedure TServerForm.ConfigurarBasicAuth;
begin
  RESTDWPoolerDB1.AuthorizationMode := amBasic;
  // Credenciais validadas no evento OnUserAuthenticate
end;

procedure TServerForm.RESTDWPoolerDB1UserAuthenticate(
  const AUserName, APassword: string;
  var Authenticated: Boolean);
begin
  // Validar credenciais contra banco de dados ou lista interna
  Authenticated := (AUserName = 'admin') and (APassword = 'senha-admin');
end;
```

```pascal
// No cliente: enviar credenciais Basic
procedure TClientForm.ConectarBasic;
begin
  RESTDWClientSQL1.UserName := 'admin';
  RESTDWClientSQL1.Password := 'senha-admin';
  RESTDWClientSQL1.Open;
end;
```

## 2. AccessTag — token fixo por cliente

```pascal
// No servidor: configurar AccessTag
procedure TServerForm.ConfigurarAccessTag;
begin
  RESTDWPoolerDB1.AuthorizationMode := amAccessTag;
end;

procedure TServerForm.RESTDWPoolerDB1AccessTagAuthenticate(
  const AAccessTag: string;
  var Authenticated: Boolean);
begin
  // Validar AccessTag — geralmente um UUID ou hash fixo por aplicação
  Authenticated := (AAccessTag = 'meu-access-tag-secreto-uuid');
end;
```

```pascal
// No cliente: enviar AccessTag
procedure TClientForm.ConectarAccessTag;
begin
  RESTDWClientSQL1.AccessTag := 'meu-access-tag-secreto-uuid';
  RESTDWClientSQL1.Open;
end;
```

## 3. JWT — obter token (NewToken endpoint)

```pascal
uses uRESTDWClientSQL, uRESTDWCripto;

procedure TClientForm.ObterTokenJWT;
var
  LToken: string;
begin
  // Requisição ao endpoint de geração de token
  RESTDWClientSQL1.Close;
  RESTDWClientSQL1.SQL.Text := '';
  RESTDWClientSQL1.RESTDWMethod := rdwPost;
  RESTDWClientSQL1.Route       := '/newtoken';

  RESTDWClientSQL1.Params.Clear;
  RESTDWClientSQL1.Params.Add.Name  := 'username';
  RESTDWClientSQL1.Params.Add.Value := 'admin';
  RESTDWClientSQL1.Params.Add.Name  := 'password';
  RESTDWClientSQL1.Params.Add.Value := 'senha-admin';

  RESTDWClientSQL1.ExecSQL;

  LToken := RESTDWClientSQL1.FieldByName('token').AsString;
  // Armazenar LToken para uso em requisições subsequentes
  FJWTToken := LToken;
end;
```

## 4. JWT — usar token Bearer em requisições

```pascal
// Configurar o token JWT no cliente antes das operações
procedure TClientForm.ConfigurarJWT(const AToken: string);
begin
  RESTDWClientSQL1.AuthorizationToken := AToken;
  RESTDWClientSQL1.AuthorizationMode  := amJWT;
  // Todas as requisições subsequentes enviarão: Authorization: Bearer <token>
end;

procedure TClientForm.ConsultarComJWT;
begin
  // Garantir que o token está configurado
  ConfigurarJWT(FJWTToken);

  RESTDWClientSQL1.Close;
  RESTDWClientSQL1.SQL.Text := 'SELECT * FROM clientes WHERE ativo = 1';
  RESTDWClientSQL1.Open;
end;
```

## 5. JWT — renovar token (RenewToken endpoint)

```pascal
procedure TClientForm.RenovarTokenJWT;
var
  LNovoToken: string;
begin
  RESTDWClientSQL1.RESTDWMethod       := rdwPost;
  RESTDWClientSQL1.Route              := '/renewtoken';
  RESTDWClientSQL1.AuthorizationToken := FJWTToken;  // token atual
  RESTDWClientSQL1.AuthorizationMode  := amJWT;

  RESTDWClientSQL1.ExecSQL;

  LNovoToken := RESTDWClientSQL1.FieldByName('token').AsString;
  FJWTToken  := LNovoToken;  // substituir pelo token renovado
end;
```

## 6. OAuth2 — fluxo de 4 passos

```pascal
// Passo 1: Redirecionar usuário para provedor OAuth2
procedure TClientForm.OAuth2IniciarFluxo;
var
  LAuthURL: string;
begin
  LAuthURL := RESTDWClientSQL1.OAuth2AuthorizationURL(
    'https://auth.provedor.com/authorize',
    'client_id_aqui',
    'https://meuapp.com/callback',
    'read write'
  );
  // Abrir LAuthURL no browser do usuário
  ShellExecute(0, 'open', PChar(LAuthURL), nil, nil, SW_SHOW);
end;

// Passo 2: Receber código de autorização no callback
// (implementado no endpoint /callback do seu servidor)

// Passo 3: Trocar código por access token
procedure TClientForm.OAuth2TrocarCodigoPorToken(const ACode: string);
begin
  RESTDWClientSQL1.OAuth2ExchangeCode(
    'https://auth.provedor.com/token',
    'client_id_aqui',
    'client_secret_aqui',
    ACode,
    'https://meuapp.com/callback'
  );
  FJWTToken := RESTDWClientSQL1.OAuth2AccessToken;
end;

// Passo 4: Usar access token nas requisições
procedure TClientForm.OAuth2UsarToken;
begin
  RESTDWClientSQL1.AuthorizationToken := FJWTToken;
  RESTDWClientSQL1.AuthorizationMode  := amOAuth2;
  RESTDWClientSQL1.Open;
end;
```
