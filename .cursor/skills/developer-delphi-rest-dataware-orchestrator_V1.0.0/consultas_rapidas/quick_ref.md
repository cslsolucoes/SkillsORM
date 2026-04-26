---
description: "Referência rápida — família developer-delphi-rest-dataware-*"
alwaysApply: false
---

# Quick Reference — developer-delphi-rest-dataware

## Skills da família

| Skill | Modelo | Usar quando |
| --- | --- | --- |
| `developer-delphi-rest-dataware-expert` | opus/extended | Arquitetura, APIs, componentes, exceções, ADRs |
| `developer-delphi-rest-dataware-roteiro` | haiku/extended | Exemplos Pascal: server, client, auth, massive, drivers |
| `developer-delphi-rest-dataware-estrutura` | haiku/minimal | Localização de arquivos, mapa de pastas, ordem de compilação |

## Padrão de uso rápido — servidor básico

```pascal
// Servidor REST mínimo com Indy
uses uRESTDWIdBase, uRESTDWPoolerDB;

var
  FServer: TRESTDWIdBase;
  FPooler: TRESTDWPoolerDB;
begin
  FPooler := TRESTDWPoolerDB.Create(nil);
  FServer := TRESTDWIdBase.Create(nil);
  FServer.RESTDWPoolerDB := FPooler;
  FServer.Port := 8082;
  FServer.Active := True;
end;
```

## Drivers disponíveis

| Driver | Diretiva em uRESTDW.inc |
| --- | --- |
| FireDAC | `{$DEFINE RESTDWFIREDAC}` |
| Zeos | `{$DEFINE RESTDWZEOS}` |
| UniDAC | `{$DEFINE RESTDWUNIDAC}` |
| Lazarus SQLdb | `{$DEFINE RESTDWSQLDB}` |
| Interbase nativo | `{$DEFINE RESTDWINTERBASE}` |
