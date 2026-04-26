---
description: "Exemplos de consultas LDAP — ActiveDirectoryORM"
alwaysApply: false
---

# Roteiro — Consultas LDAP (ActiveDirectoryORM)

> Fonte canônica: `app/modules/ActiveDirectoryORM/Documentation/Fundamentos/01-API-Nucleo.md`

## 1. SearchObjects — busca com filtro simples

```pascal
uses ActiveDirectory.Main, ActiveDirectory.Service, ActiveDirectory.Helpers, ActiveDirectory.Consts;

var
  LSvc: IActiveDirectoryService;
  LAttrs: TStringList;
  LResults: TObjectList;
  LFilter: string;
begin
  // (criar LSvc com configuração)

  LAttrs := TStringList.Create;
  try
    TActiveDirectoryHelper.AddDefaultAttributesForUserSearch(LAttrs);

    LFilter := TActiveDirectoryHelper.BuildFilterWithObjectClass(
      LDAP_OBJECTCLASS_USER, LDAP_ATTR_SAM, 'joao*'
    );
    // LFilter = '(&(objectClass=user)(sAMAccountName=joao*))'

    LSvc.Connect;
    LResults := LSvc.SearchObjects(LFilter, LAttrs);
    try
      // processar resultados
    finally
      LResults.Free;
    end;
  finally
    LAttrs.Free;
    LSvc.Disconnect;
  end;
end;
```

## 2. SearchWithCustomFilter — filtro personalizado

```pascal
var
  LSvc: IActiveDirectoryService;
  LAttrs, LOrFilters: TStringList;
  LResults: TObjectList;
begin
  LAttrs := TStringList.Create;
  LOrFilters := TStringList.Create;
  try
    TActiveDirectoryHelper.AddDefaultAttributesForDetailedSearch(LAttrs);

    // Filtro OR: busca por SAM ou email
    LOrFilters.Add(LDAP_ATTR_SAM + '=joao.silva');
    LOrFilters.Add('mail=joao@empresa.com');

    LSvc.Connect;
    LResults := LSvc.SearchWithCustomFilter(
      TActiveDirectoryHelper.BuildFilterMultiple(LOrFilters),
      LAttrs
    );
    // LFilter = '(|(sAMAccountName=joao.silva)(mail=joao@empresa.com))'
    try
      // processar resultados
    finally
      LResults.Free;
    end;
  finally
    LAttrs.Free;
    LOrFilters.Free;
    LSvc.Disconnect;
  end;
end;
```

## 3. ListGroups — listar grupos nas OUs

```pascal
var
  LSvc: IActiveDirectoryService;
  LSearchOUs: TStringList;
  LGroups: TObjectList;
begin
  LSearchOUs := TStringList.Create;
  try
    LSearchOUs.Add('OU=Grupos,DC=empresa,DC=com');
    LSearchOUs.Add('OU=GruposTI,DC=empresa,DC=com');

    LSvc.Connect;
    LGroups := LSvc.ListGroups(LSearchOUs);
    try
      // LGroups contém TLDAPEntry de cada grupo
      // Entry.Attributes: lista de pares Atributo=Valor
    finally
      LGroups.Free;
    end;
  finally
    LSearchOUs.Free;
    LSvc.Disconnect;
  end;
end;
```

## 4. GetGroupMembers — membros de um grupo

```pascal
var
  LSvc: IActiveDirectoryService;
  LMembers: TStringList;
  I: Integer;
begin
  LSvc.Connect;
  LMembers := LSvc.GetGroupMembers('CN=GrupoTI,OU=Grupos,DC=empresa,DC=com');
  try
    for I := 0 to LMembers.Count - 1 do
      ShowMessage('Membro DN: ' + LMembers[I]);
    // Retorna lista de DNs (distinguishedName) dos membros
  finally
    LMembers.Free;
    LSvc.Disconnect;
  end;
end;
```

## 5. GetObjectAttributes — atributos de um objeto específico

```pascal
var
  LSvc: IActiveDirectoryService;
  LRequestAttrs, LResultAttrs: TStringList;
  LMail: string;
begin
  LRequestAttrs := TStringList.Create;
  try
    LRequestAttrs.Add('mail');
    LRequestAttrs.Add('displayName');
    LRequestAttrs.Add('telephoneNumber');
    LRequestAttrs.Add(LDAP_ATTR_SAM);

    LSvc.Connect;
    LResultAttrs := LSvc.GetObjectAttributes(
      'CN=João Silva,OU=Usuarios,DC=empresa,DC=com',
      LRequestAttrs
    );
    try
      LMail := TActiveDirectoryHelper.GetAttributeValueFromList(LResultAttrs, 'mail');
      ShowMessage('Email: ' + LMail);
    finally
      LResultAttrs.Free;
    end;
  finally
    LRequestAttrs.Free;
    LSvc.Disconnect;
  end;
end;
```

## 6. ListContainerObjects — listar objetos de um container/OU

```pascal
var
  LSvc: IActiveDirectoryService;
  LObjects: TObjectList;
  I: Integer;
  LEntry: TLDAPEntry;
begin
  LSvc.Connect;
  LObjects := LSvc.ListContainerObjects('OU=Usuarios,DC=empresa,DC=com');
  try
    for I := 0 to LObjects.Count - 1 do
    begin
      LEntry := TLDAPEntry(LObjects[I]);
      ShowMessage(
        TActiveDirectoryHelper.GetCommonName(LEntry.DN) +
        ' [' + TActiveDirectoryHelper.GetObjectClassFromAttributes(LEntry.Attributes) + ']'
      );
    end;
  finally
    LObjects.Free;
    LSvc.Disconnect;
  end;
end;
```
