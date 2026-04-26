---
description: "Mapa rápido — onde fica cada camada no repositório ProvidersORM"
alwaysApply: false
---

# Quick Reference — documentation-project-structure

| Camada | Path relativo à raiz do workspace |
|--------|-----------------------------------|
| Tipos/Enums compartilhados | `src/Commons/Commons.Types.pas` |
| Constantes compartilhadas | `src/Commons/Commons.Consts.pas` |
| Utilitários compartilhados | `src/Commons/Commons.Base.pas` |
| Facade pública | `src/Main/` (Exceptions.Interfaces, Parameters.Interfaces, Loggers.Interfaces) |
| Conexão | `src/Modulos/Connections/` |
| Pool de conexões | `src/Modulos/PoolConnections/` |
| ORM DDL/DML | `src/Modulos/Database/` (Field, Table, Schema, EntityManager, QueryBuilder, TypeDatabase) |
| Exceções centralizadas | `src/Modulos/Exceptions/` |
| Parâmetros (INI/JSON/DB) | `src/Modulos/Parameters/` |
| Loggers (multi-destino) | `src/Modulos/Loggers/` |
| Atributos RTTI | `src/Attributers/` |
| Forms de teste | `src/Views/` |
| Diretivas de compilação | `ORM.Defines.inc` (raiz do projeto) |
| Documentação canônica | `Documentation/` (Analise/, Arquitetura/, Regras de Negocio/, Roadmap/) |
| Base de exceções (SQLite) | `Data/exception.db` / `Data/exception.sql` |

## Regra de navegação

1. Para convenções → `documentation-project-expert`
2. Para onde criar arquivos → esta tabela
3. Para `{$IFDEF}` → `developer-delphi-programming-conditional-defines`
4. Para exemplos de uso → `developer-delphi-providers-orm-usage`
