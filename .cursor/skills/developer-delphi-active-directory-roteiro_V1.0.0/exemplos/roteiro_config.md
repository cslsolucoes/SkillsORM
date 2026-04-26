---
description: "Exemplos de configuração de conexão LDAP — ActiveDirectoryORM"
alwaysApply: false
---

# Roteiro — Configuração LDAP (ActiveDirectoryORM)

> Fonte canônica: `app/modules/ActiveDirectoryORM/Documentation/Fundamentos/02-Exemplos-Completos.md`

## 1. Configuração mínima fluente

```pascal
uses ActiveDirectory.Main.Interfaces, ActiveDirectory.Main, ActiveDirectory.Types;

var
  LCfg: TLDAPConfig;
begin
  LCfg := TActiveDirectory.New
    .Host('ldap.empresa.com')
    .Port(LDAP_PORT_DEFAULT)        // 389
    .BaseDN('DC=empresa,DC=com')
    .BaseAuth('CN=svc-ldap,OU=Servicos,DC=empresa,DC=com')
    .Username('svc-ldap')
    .Password('senha-servico')
    .GetConfig;
  // LCfg agora contém a configuração completa
end;
```

## 2. Configuração SSL/LDAPS

`UseSSL(True)` ajusta automaticamente a porta de 389 para 636. `UseSSL(False)` reverte 636 para 389.

```pascal
var
  LCfg: TLDAPConfig;
begin
  LCfg := TActiveDirectory.New
    .Host('ldap.empresa.com')
    .UseSSL(True)                   // porta ajustada para 636 automaticamente
    .BaseDN('DC=empresa,DC=com')
    .BaseAuth('CN=svc-ldap,OU=Servicos,DC=empresa,DC=com')
    .Username('svc-ldap')
    .Password('senha-servico')
    .GetConfig;
  // LCfg.UseSSL = True, LCfg.Port = 636
end;
```

## 3. Múltiplas OUs de busca (encadeadas)

```pascal
var
  LCfg: TLDAPConfig;
begin
  LCfg := TActiveDirectory.New
    .Host('ldap.empresa.com')
    .BaseDN('DC=empresa,DC=com')
    .BaseAuth('CN=svc-ldap,OU=Servicos,DC=empresa,DC=com')
    .Password('senha-servico')
    .AddSearchOU('OU=Usuarios,DC=empresa,DC=com')
    .AddSearchOU('OU=Terceiros,DC=empresa,DC=com')
    .AddSearchOU('OU=Admin,DC=empresa,DC=com')
    .GetConfig;
  // LCfg.SearchOUs contém 3 OUs (sem duplicatas)
end;
```

## 4. Configuração via TStringList (Chave=Valor)

```pascal
var
  LList: TStringList;
  LConn: IActiveDirectoryConnection;
begin
  LList := TStringList.Create;
  try
    LList.Add('Host=ldap.empresa.com');
    LList.Add('Port=389');
    LList.Add('BaseDN=DC=empresa,DC=com');
    LList.Add('BaseAuth=CN=svc-ldap,OU=Servicos,DC=empresa,DC=com');
    LList.Add('Username=svc-ldap');
    LList.Add('Password=senha-servico');
    LList.Add('UseSSL=False');
    LList.Add('TimeOut=30');
    LList.Add('Version=3');

    LConn := TActiveDirectory.New.SetConfig(LList);
    // continuar configuração adicional se necessário
  finally
    LList.Free;
  end;
end;
```

## 5. Configuração via JSON object

```pascal
uses System.JSON;

var
  LJson: TJSONObject;
  LCfg: TLDAPConfig;
begin
  LJson := TJSONObject.Create;
  try
    LJson.AddPair('Host', 'ldap.empresa.com');
    LJson.AddPair('Port', TJSONNumber.Create(389));
    LJson.AddPair('BaseDN', 'DC=empresa,DC=com');
    LJson.AddPair('BaseAuth', 'CN=svc-ldap,OU=Servicos,DC=empresa,DC=com');
    LJson.AddPair('Username', 'svc-ldap');
    LJson.AddPair('Password', 'senha-servico');
    LJson.AddPair('UseSSL', TJSONBool.Create(False));

    LCfg := TActiveDirectory.New.SetConfig(LJson).GetConfig;
  finally
    LJson.Free;
  end;
end;
```

## 6. Reuso de configuração (GetConfig + SetConfig)

```pascal
var
  LCfg: TLDAPConfig;
  LConn1, LConn2: IActiveDirectoryConnection;
begin
  // Configuração base
  LCfg := TActiveDirectory.New
    .Host('ldap.empresa.com')
    .BaseDN('DC=empresa,DC=com')
    .BaseAuth('CN=svc-ldap,OU=Servicos,DC=empresa,DC=com')
    .Password('senha-servico')
    .GetConfig;

  // Reusar configuração em nova instância com ajuste pontual
  LConn2 := TActiveDirectory.New
    .SetConfig(LCfg)
    .UseSSL(True)                  // ajuste sobre a config existente
    .AddSearchOU('OU=Admin,DC=empresa,DC=com');
end;
```

## 7. Constantes de porta (nunca hardcode)

```pascal
uses ActiveDirectory.Consts;

var
  LCfg: TLDAPConfig;
begin
  // CORRETO: usar constantes
  LCfg := TActiveDirectory.New
    .Host('ldap.empresa.com')
    .Port(LDAP_PORT_DEFAULT)        // 389 — não escrever 389 diretamente
    .GetConfig;

  // Para LDAPS: usar UseSSL(True) que ajusta automaticamente
  // OU especificar a constante explicitamente
  LCfg := TActiveDirectory.New
    .Host('ldap.empresa.com')
    .Port(LDAPS_PORT_DEFAULT)       // 636
    .UseSSL(True)
    .GetConfig;
end;
```
