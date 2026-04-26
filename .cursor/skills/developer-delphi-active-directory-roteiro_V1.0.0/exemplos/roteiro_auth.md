---
description: "Exemplos de autenticação LDAP — ActiveDirectoryORM"
alwaysApply: false
---

# Roteiro — Autenticação LDAP (ActiveDirectoryORM)

> Fonte canônica: `app/modules/ActiveDirectoryORM/Documentation/Regras de Negocio/RN-AD-01_Autenticacao_V1.0.md`

## 1. TestConnection — verificar conectividade e credenciais de serviço

```pascal
uses ActiveDirectory.Main, ActiveDirectory.Types, ActiveDirectory.Service;

var
  LCfg: TLDAPConfig;
  LSvc: IActiveDirectoryService;
begin
  LCfg := TActiveDirectory.New
    .Host('ldap.empresa.com')
    .BaseDN('DC=empresa,DC=com')
    .BaseAuth('CN=svc-ldap,OU=Servicos,DC=empresa,DC=com')
    .Password('senha-servico')
    .GetConfig;

  LSvc := TActiveDirectoryService.New(LCfg);
  if LSvc.TestConnection then
    ShowMessage('Servidor LDAP acessível')
  else
    ShowMessage('Falha: ' + LSvc.LastError);
end;
```

## 2. Authenticate — autenticação por sAMAccountName ou UPN

Busca o usuário em `SearchOUs` pelos atributos cn, distinguishedName, sAMAccountName e userPrincipalName, depois faz Bind com as credenciais fornecidas.

```pascal
var
  LCfg: TLDAPConfig;
  LSvc: IActiveDirectoryService;
begin
  LCfg := TActiveDirectory.New
    .Host('ldap.empresa.com')
    .BaseDN('DC=empresa,DC=com')
    .BaseAuth('CN=svc-ldap,OU=Servicos,DC=empresa,DC=com')
    .Password('senha-servico')
    .AddSearchOU('OU=Usuarios,DC=empresa,DC=com')
    .GetConfig;

  LSvc := TActiveDirectoryService.New(LCfg);

  if LSvc.Authenticate('joao.silva', 'senha-do-usuario') then
    ShowMessage('Autenticado com sucesso')
  else
  begin
    // Authenticate retorna False e armazena erro em LastError
    // Não lança exceção por padrão
    ShowMessage('Falha de autenticação: ' + LSvc.LastError);
  end;
end;
```

**Modos de username aceitos:**

- `joao.silva` (sAMAccountName)
- `joao.silva@empresa.com` (userPrincipalName)
- `CN=João Silva,OU=Usuarios,DC=empresa,DC=com` (distinguishedName)
- `João Silva` (cn)

## 3. AuthenticateUser — bind direto por DN completo

Não faz busca — faz Bind direto com o DN e senha fornecidos. Mais eficiente quando o DN já é conhecido.

```pascal
var
  LCfg: TLDAPConfig;
  LSvc: IActiveDirectoryService;
  LUserDN: string;
begin
  LCfg := TActiveDirectory.New
    .Host('ldap.empresa.com')
    .BaseDN('DC=empresa,DC=com')
    .BaseAuth('CN=svc-ldap,OU=Servicos,DC=empresa,DC=com')
    .Password('senha-servico')
    .GetConfig;

  LUserDN := 'CN=João Silva,OU=Usuarios,DC=empresa,DC=com';
  LSvc := TActiveDirectoryService.New(LCfg);

  if LSvc.AuthenticateUser(LUserDN, 'senha-do-usuario') then
    ShowMessage('Autenticado com sucesso')
  else
    ShowMessage('Falha: ' + LSvc.LastError);
end;
```

## 4. Tratamento de erros e LastError

```pascal
var
  LSvc: IActiveDirectoryService;
begin
  // ... (criar LSvc com configuração)

  try
    if not LSvc.Connect then
    begin
      // EADConnectionException pode ser lançada aqui
      ShowMessage('Erro de conexão: ' + LSvc.LastError);
      Exit;
    end;

    if not LSvc.Authenticate('usuario', 'senha') then
    begin
      // LastError contém mensagem do servidor LDAP
      // Não há exceção — verificar retorno booleano
      if LSvc.LastError <> '' then
        ShowMessage('Detalhe do erro: ' + LSvc.LastError)
      else
        ShowMessage('Autenticação negada (sem detalhe disponível)');
    end;
  except
    on E: EADConfigurationException do
      ShowMessage('Configuração inválida: ' + E.Message);
    on E: EADValidationException do
      ShowMessage('Parâmetro inválido: ' + E.Message);
    on E: EADException do
      ShowMessage('Erro AD [' + IntToStr(E.ErrorCode) + ']: ' + E.Message);
  end;
end;
```
