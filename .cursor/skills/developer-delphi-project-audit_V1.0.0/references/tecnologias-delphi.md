# Referência de Tecnologias Delphi

## Histórico de Versões do Delphi

| Versão | Ano | Nome Comercial | Status |
|--------|-----|----------------|--------|
| Delphi 1 | 1995 | Delphi 1 | ❌ Obsoleto |
| Delphi 2 | 1996 | Delphi 2 | ❌ Obsoleto |
| Delphi 3 | 1997 | Delphi 3 | ❌ Obsoleto |
| Delphi 4 | 1998 | Delphi 4 | ❌ Obsoleto |
| Delphi 5 | 1999 | Delphi 5 | ❌ Obsoleto |
| Delphi 6 | 2001 | Delphi 6 | ❌ Obsoleto |
| Delphi 7 | 2002 | Delphi 7 | ⚠️ Muito usado (legado) |
| Delphi 8 | 2003 | Delphi 8 (.NET) | ❌ Descontinuado |
| Delphi 2005 | 2004 | Delphi 9 | ❌ Obsoleto |
| Delphi 2006 | 2005 | Delphi 10 | ❌ Obsoleto |
| Delphi 2007 | 2007 | Delphi 11 | ⚠️ Legado |
| Delphi 2009 | 2008 | Delphi 12 | ⚠️ Unicode nativo |
| Delphi 2010 | 2009 | Delphi 14 | ⚠️ Legado |
| Delphi XE | 2010 | Delphi 15 | ⚠️ Legado |
| Delphi XE2 | 2011 | Delphi 16 | ⚠️ Legado (FMX introduzido) |
| Delphi XE3–XE8 | 2012–2015 | — | ⚠️ Legado |
| Delphi 10 Seattle | 2015 | Delphi 20 | ⚠️ Suporte encerrado |
| Delphi 10.1 Berlin | 2016 | — | ⚠️ Suporte encerrado |
| Delphi 10.2 Tokyo | 2017 | — | ⚠️ Suporte encerrado |
| Delphi 10.3 Rio | 2018 | — | ⚠️ Suporte encerrado |
| Delphi 10.4 Sydney | 2020 | — | ✅ Suportado |
| Delphi 11 Alexandria | 2021 | — | ✅ Suportado |
| Delphi 12 Athens | 2023 | — | ✅ Atual/Recomendado |

---

## Componentes de Acesso a Dados

### BDE (Borland Database Engine)
- **Status**: ❌ OBSOLETO — NÃO USAR
- **Problema**: Não é suportado oficialmente no Windows 8+ sem hacks de compatibilidade
- **Banco suportados**: Paradox, dBase, Interbase (via ODBC)
- **Risco**: Falhas silenciosas no Windows 10/11, não funciona em 64-bit
- **Migração recomendada**: FireDAC

### ADO (ActiveX Data Objects)
- **Status**: ⚠️ LEGADO — Funciona mas sem evolução
- **Componentes**: TADOConnection, TADOQuery, TADOTable, TADOStoredProc
- **Bancos suportados**: SQL Server, Access, Oracle, MySQL (via ODBC)
- **Risco**: Dependência de drivers ODBC, sem suporte a features modernas
- **Migração recomendada**: FireDAC

### DBExpress
- **Status**: ⚠️ LEGADO — Presente até Delphi 12, mas não evoluído
- **Componentes**: TSQLConnection, TSQLQuery, TSQLDataSet
- **Bancos suportados**: Interbase, MySQL, Oracle, DB2, MSSQL
- **Migração recomendada**: FireDAC

### IBX (InterBase Express)
- **Status**: ⚠️ LEGADO para versões antigas; ✅ ativo no IBX for Firebird (Firebird Pascal)
- **Específico para**: InterBase e Firebird
- **Alternativa atual**: IBX da MWA Software (open source) ou FireDAC

### FireDAC
- **Status**: ✅ ATUAL — Recomendado pela Embarcadero
- **Disponível desde**: Delphi XE3 (como AnyDAC), renomeado no XE5
- **Componentes**: TFDConnection, TFDQuery, TFDTable, TFDStoredProc, TFDTransaction
- **Bancos suportados**: Firebird, Oracle, MSSQL, MySQL/MariaDB, SQLite, PostgreSQL, MongoDB, Interbase, DB2, Informix, e mais
- **Vantagens**: Alta performance, suporte a 64-bit, array DML, local SQL, offline caching

### Zeos (ZeosLib)
- **Status**: ✅ Open Source — Mantido pela comunidade
- **Componentes**: TZConnection, TZQuery, TZTable
- **Bancos suportados**: PostgreSQL, MySQL, Firebird, SQLite, Oracle, MSSQL
- **Uso comum**: Projetos que não têm licença FireDAC

### UniDAC (Devart)
- **Status**: ✅ Comercial — Bem mantido
- **Bancos suportados**: Ampla gama, incluindo cloud databases

---

## Componentes de Interface (VCL)

### Nativos Embarcadero/Borland
- TDBGrid, TDBEdit, TDBNavigator — padrão, sem licença extra
- TPageControl, TTabSheet, TPanel — layout básico

### DevExpress VCL
- **Status**: ✅ Ativo e popular
- **Componentes chave**: TcxGrid, TdxRibbon, TdxNavBar, TdxSpreadSheet
- **Atenção**: Verificar versão instalada vs versão do Delphi

### TMS Software
- **Status**: ✅ Ativo
- **Componentes chave**: TTMSFNCGrid, TAdvStringGrid, TDBAdvGrid

### Raize Components / Konopka
- **Status**: ⚠️ Suporte encerrado — incluído no Delphi XE8+

### JVCL (JEDI VCL)
- **Status**: ✅ Open Source — comunidade ativa
- **Componentes chave**: TJvDBGrid, TJvValidateEdit, TJvXPBar

---

## Frameworks de Relatório

### FastReport
- **Status**: ✅ Ativo e popular no Brasil
- **Versões**: FastReport 4 (legado), FastReport 5, FastReport 6
- **Atenção**: Versões antigas não são compatíveis com Delphi 12

### ReportBuilder (Digital Metaphors)
- **Status**: ⚠️ Ativo mas menos popular no Brasil
- **Uso**: Mais comum em projetos north-americanos

### Rave Reports
- **Status**: ❌ Descontinuado (era nativo do Delphi 7/2007)

### QuickReport
- **Status**: ❌ Praticamente obsoleto

### ACBr Report (NFe/NFCe)
- **Status**: ✅ Ativo — projeto open source brasileiro

---

## Frameworks e Bibliotecas Populares

### ACBr
- **Status**: ✅ MUITO USADO no Brasil
- **Finalidade**: NFe, NFCe, CTe, MDFe, SAT, TEF, Boleto, SPED, eSocial
- **Licença**: Open Source (LGPL)

### Boss (Package Manager)
- **Status**: ✅ Moderno — gerenciador de pacotes para Delphi
- **Uso**: Gerenciar dependências via linha de comando

### Horse (Web Framework)
- **Status**: ✅ Ativo — framework HTTP para APIs REST em Delphi
- **Uso**: Desenvolvimento de back-end/API em Delphi

### mORMot
- **Status**: ✅ Ativo — framework ORM, REST, SOA
- **Uso**: Sistemas com necessidade de alta performance e ORM

### Spring4D
- **Status**: ✅ Ativo — framework de injeção de dependência
- **Uso**: Projetos que seguem padrões SOLID

---

## Compatibilidade de SO e Arquitetura

| Tecnologia | Win XP | Win 7 | Win 10 | Win 11 | 32-bit | 64-bit |
|-----------|--------|-------|--------|--------|--------|--------|
| BDE | ✅ | ⚠️ | ⚠️ hack | ❌ | ✅ | ❌ |
| ADO | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| FireDAC | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Delphi 7 compilado | ✅ | ✅ | ⚠️ | ⚠️ | ✅ | ❌ |
| Delphi 10+ compilado | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Delphi 12 compilado | ❌ | ⚠️ | ✅ | ✅ | ✅ | ✅ |

---

## Guia de Riscos por Tecnologia

### BDE em produção → 🚨 RISCO CRÍTICO
```
Problemas conhecidos:
- Limite de 2GB para arquivos de banco Paradox/dBase
- Incompatibilidade com Windows 11 sem patches
- Impossível compilar para 64-bit
- Sem suporte oficial desde Delphi 2007
- Problemas com DPI alto (HiDPI)
Ação: Migrar para FireDAC URGENTEMENTE
```

### Delphi 7 ou anterior → ⚠️ ATENÇÃO
```
Problemas conhecidos:
- Sem suporte a Unicode nativo (Delphi < 2009)
- Strings são AnsiString — problemas com caracteres especiais
- Sem suporte a 64-bit
- Componentes VCL antigos com problemas de DPI
Ação: Planejar migração do compilador
```

### Ausência de tratamento de exceções → ⚠️ ATENÇÃO
```
Sintomas: Sem try/except, avisos diretos ao usuário do SGBD
Impacto: Sistema instável, dados inconsistentes
Ação: Refatoração progressiva com tratamento estruturado
```
