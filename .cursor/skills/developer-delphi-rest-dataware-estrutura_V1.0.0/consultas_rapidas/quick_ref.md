---
description: "Referência rápida — estrutura de arquivos do REST DataWare"
alwaysApply: false
---

# Quick Reference — developer-delphi-rest-dataware-estrutura

## Camada → Path → Conteúdo

| Camada | Path | Conteúdo |
| --- | --- | --- |
| Config | `CORE/Source/uRESTDW.inc` | Diretivas de compilação (driver + transporte) |
| Transporte Indy | `CORE/Source/Sockets/uRESTDWIdBase.pas` | TRESTDWIdBase (servidor padrão) |
| Transporte FpHttp | `CORE/Source/Sockets/uRESTDWFpHttpBase.pas` | TRESTDWFpHttpBase (Lazarus) |
| Core client | `CORE/Source/Basic/uRESTDWClientSQL.pas` | TRESTDWClientSQL |
| Pool | `CORE/Source/Basic/uRESTDWPoolerDB.pas` | TRESTDWPoolerDB |
| Batch | `CORE/Source/Basic/uRESTDWMassiveCache.pas` | TRESTDWMassiveCache |
| Cripto/JWT | `CORE/Source/Basic/Crypto/uRESTDWCripto.pas` | TCripto |
| Driver base | `CORE/Source/Database_Drivers/uRESTDWDriverBase.pas` | TRESTDWDriverBase |
| Driver FireDAC | `CORE/Source/Database_Drivers/uRESTDWFireDAC.pas` | Implementação FireDAC |
| Driver Zeos | `CORE/Source/Database_Drivers/uRESTDWZeos.pas` | Implementação Zeos |
| Driver SQLdb | `CORE/Source/Database_Drivers/uRESTDWSQLdb.pas` | Implementação SQLdb |
| Exceções | `CORE/Source/uRESTDWException.pas` | eRESTDWException + 11 subclasses |

## Ordem de compilação

1. `RESTDWRuntime`
2. Driver escolhido (ex.: `RESTDWFireDAC`)
3. `RESTDWDesigntime`
4. Pacote de transporte (ex.: `RESTDWIndy`)
