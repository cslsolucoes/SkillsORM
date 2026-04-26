---
description: "Exemplos de operações de escrita LDAP — ActiveDirectoryORM"
alwaysApply: false
---

# Roteiro — Operações de Escrita LDAP (ActiveDirectoryORM)

> Fonte canônica: `app/modules/ActiveDirectoryORM/Documentation/Regras de Negocio/RN-AD-02_OperacoesEscrita_V1.0.md`

## 1. SetAttributeValue — substituir valor de atributo (Replace)

```pascal
uses ActiveDirectory.Main, ActiveDirectory.Types, ActiveDirectory.Service;

var
  LSvc: IActiveDirectoryService;
  LUserDN: string;
begin
  LUserDN := 'CN=João Silva,OU=Usuarios,DC=empresa,DC=com';

  LSvc.Connect;
  try
    // Replace: substitui o valor existente pelo novo
    LSvc.SetAttributeValue(LUserDN, 'telephoneNumber', '+55 11 9999-0000');
    LSvc.SetAttributeValue(LUserDN, 'department', 'Tecnologia da Informação');
  finally
    LSvc.Disconnect;
  end;
end;
```

## 2. AddAttributeValue — adicionar valor a atributo multivalorado (Add)

```pascal
var
  LSvc: IActiveDirectoryService;
  LGroupDN: string;
begin
  LGroupDN := 'CN=GrupoTI,OU=Grupos,DC=empresa,DC=com';

  LSvc.Connect;
  try
    // Add: adiciona valor sem remover os existentes (atributo multivalorado)
    LSvc.AddAttributeValue(
      LGroupDN,
      'proxyAddresses',
      'SMTP:grupoTI@empresa.com'
    );
  finally
    LSvc.Disconnect;
  end;
end;
```

## 3. DeleteAttributeValue — remover valor de atributo multivalorado (Delete)

```pascal
var
  LSvc: IActiveDirectoryService;
  LUserDN: string;
begin
  LUserDN := 'CN=João Silva,OU=Usuarios,DC=empresa,DC=com';

  LSvc.Connect;
  try
    // Delete: remove o valor específico do atributo multivalorado
    LSvc.DeleteAttributeValue(
      LUserDN,
      'proxyAddresses',
      'smtp:joao.antigo@empresa.com'
    );
  finally
    LSvc.Disconnect;
  end;
end;
```

## 4. SetAttributes — modificar múltiplos atributos em uma operação

```pascal
var
  LSvc: IActiveDirectoryService;
  LAttrs: TStringList;
  LUserDN: string;
begin
  LUserDN := 'CN=João Silva,OU=Usuarios,DC=empresa,DC=com';

  LAttrs := TStringList.Create;
  try
    // Formato: Atributo=Valor (pares)
    LAttrs.Add('mail=joao.silva@empresa.com');
    LAttrs.Add('displayName=João da Silva');
    LAttrs.Add('title=Analista Sênior');
    LAttrs.Add('department=TI');

    LSvc.Connect;
    try
      LSvc.SetAttributes(LUserDN, LAttrs);
    finally
      LSvc.Disconnect;
    end;
  finally
    LAttrs.Free;
  end;
end;
```

## 5. AddObject — criar novo objeto no AD

```pascal
var
  LSvc: IActiveDirectoryService;
  LNewDN: string;
  LAttrs: TStringList;
begin
  LNewDN := 'CN=Pedro Costa,OU=Usuarios,DC=empresa,DC=com';

  LAttrs := TStringList.Create;
  try
    LAttrs.Add('objectClass=user');
    LAttrs.Add('sAMAccountName=pedro.costa');
    LAttrs.Add('userPrincipalName=pedro.costa@empresa.com');
    LAttrs.Add('displayName=Pedro Costa');
    LAttrs.Add('mail=pedro.costa@empresa.com');

    LSvc.Connect;
    try
      LSvc.AddObject(LNewDN, LAttrs);
    finally
      LSvc.Disconnect;
    end;
  finally
    LAttrs.Free;
  end;
end;
```

## 6. DeleteObject — remover objeto do AD

```pascal
var
  LSvc: IActiveDirectoryService;
  LDN: string;
begin
  LDN := 'CN=Pedro Costa,OU=Usuarios,DC=empresa,DC=com';

  LSvc.Connect;
  try
    LSvc.DeleteObject(LDN);
  finally
    LSvc.Disconnect;
  end;
end;
```

## 7. RenameObject — mover/renomear objeto (ModifyDN)

```pascal
var
  LSvc: IActiveDirectoryService;
  LOldDN, LNewRDN, LNewParent: string;
begin
  LOldDN    := 'CN=Pedro Costa,OU=Terceiros,DC=empresa,DC=com';
  LNewRDN   := 'CN=Pedro Costa';                              // novo RDN (nome relativo)
  LNewParent:= 'OU=Usuarios,DC=empresa,DC=com';               // nova OU pai

  LSvc.Connect;
  try
    // Move: mantém o RDN igual, altera a OU pai
    LSvc.RenameObject(LOldDN, LNewRDN, LNewParent);
  finally
    LSvc.Disconnect;
  end;
end;
```

## 8. AddMemberToGroup / RemoveMemberFromGroup — gerenciar membros de grupo

```pascal
var
  LSvc: IActiveDirectoryService;
  LGroupDN, LMemberDN: string;
begin
  LGroupDN  := 'CN=GrupoTI,OU=Grupos,DC=empresa,DC=com';
  LMemberDN := 'CN=João Silva,OU=Usuarios,DC=empresa,DC=com';

  LSvc.Connect;
  try
    // Adicionar membro
    LSvc.AddMemberToGroup(LGroupDN, LMemberDN);

    // Para remover membro:
    // LSvc.RemoveMemberFromGroup(LGroupDN, LMemberDN);
  finally
    LSvc.Disconnect;
  end;
end;
```

## 9. ChangePassword — alterar senha (requer UseSSL=True)

> **Regra ADR DA-04:** ChangePassword requer conexão SSL/LDAPS. O AD rejeita
> a operação em conexão não criptografada. Usar `UseSSL(True)` na configuração
> — a porta é ajustada automaticamente para 636.
>
> A senha é codificada em **UTF-16LE** com aspas duplas antes do envio.

```pascal
uses ActiveDirectory.Main, ActiveDirectory.Types, ActiveDirectory.Service;

var
  LCfg: TLDAPConfig;
  LSvc: IActiveDirectoryService;
  LUserDN: string;
begin
  LCfg := TActiveDirectory.New
    .Host('ldap.empresa.com')
    .UseSSL(True)                         // OBRIGATÓRIO para ChangePassword
    .BaseDN('DC=empresa,DC=com')
    .BaseAuth('CN=svc-ldap,OU=Servicos,DC=empresa,DC=com')
    .Password('senha-servico')
    .GetConfig;

  LSvc := TActiveDirectoryService.New(LCfg);
  LUserDN := 'CN=João Silva,OU=Usuarios,DC=empresa,DC=com';

  try
    if not LSvc.ChangePassword(LUserDN, 'senha-antiga', 'nova-Senha@2025') then
      ShowMessage('Falha ao alterar senha: ' + LSvc.LastError)
    else
      ShowMessage('Senha alterada com sucesso');
  except
    on E: EADWriteException do
      ShowMessage('Erro de escrita [' + IntToStr(E.ErrorCode) + ']: ' + E.Message);
    on E: EADException do
      ShowMessage('Erro AD: ' + E.Message);
  end;
end;
```
