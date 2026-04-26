---
name: developer-delphi-firedac-connection
description: >
  TFDConnection, drivers FireDAC, configuração de conexão por código e por arquivo .ini,
  connection pooling, multi-banco (SQL Server, MySQL, PostgreSQL, SQLite, Firebird,
  InterBase), login prompt, deployment de drivers, FDManager, connection definitions.
  Ativar quando o usuário mencionar: conectar banco Delphi, TFDConnection, FireDAC driver,
  connection string FireDAC, SQL Server FireDAC, MySQL FireDAC, PostgreSQL FireDAC,
  SQLite FireDAC, Firebird FireDAC, pool de conexões FireDAC, FDManager, .ini FireDAC,
  driver FireDAC, deploy FireDAC, definição de conexão FireDAC.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-firedac-connection

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | FireDAC — Data Access |

## Responsabilidade única

Configurar e gerenciar a conexão FireDAC: drivers, parâmetros por banco, pooling,
arquivo de definições `.ini`, FDManager e deployment de drivers nativos.

## When to use

- Configurar `TFDConnection` para qualquer banco (SQL Server, MySQL, PostgreSQL, SQLite, Firebird)
- Definir parâmetros de conexão por código ou por arquivo `.ini`
- Implementar connection pooling
- Gerenciar múltiplas conexões com `TFDManager`
- Tratar erros de conexão e reconexão automática
- Resolver problemas de deployment de drivers

## When NOT to use

- Executar queries → `developer-delphi-firedac-queries`
- Gerenciar transações → `developer-delphi-firedac-transactions`
- Visão geral FireDAC → `developer-delphi-firedac-orchestrator`

---

## §1 — Configuração por banco

### SQL Server (MSSQL)

```pascal
uses
  FireDAC.Comp.Client,
  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL;

procedure TdmConexao.ConectarSQLServer(
  const AServidor, ABanco, AUsuario, ASenha: string);
begin
  FDConnection1.Close;
  FDConnection1.DriverName := 'MSSQL';
  FDConnection1.Params.Clear;
  FDConnection1.Params.Add('Server='   + AServidor);
  FDConnection1.Params.Add('Database=' + ABanco);
  FDConnection1.Params.Add('User_Name='+ AUsuario);
  FDConnection1.Params.Add('Password=' + ASenha);
  FDConnection1.Params.Add('OSAuthent=No');
  FDConnection1.LoginPrompt := False;
  FDConnection1.Open;
end;

// Windows Authentication (sem usuário/senha)
procedure TdmConexao.ConectarSQLServerWindowsAuth(
  const AServidor, ABanco: string);
begin
  FDConnection1.Params.Add('OSAuthent=Yes');
  // não adicionar User_Name nem Password
  FDConnection1.Open;
end;
```

### MySQL

```pascal
uses FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL;

procedure TdmConexao.ConectarMySQL(
  const AHost: string; APorta: Integer;
  const ABanco, AUsuario, ASenha: string);
begin
  FDConnection1.DriverName := 'MySQL';
  FDConnection1.Params.Clear;
  FDConnection1.Params.Add('Server='   + AHost);
  FDConnection1.Params.Add('Port='     + APorta.ToString);
  FDConnection1.Params.Add('Database=' + ABanco);
  FDConnection1.Params.Add('User_Name='+ AUsuario);
  FDConnection1.Params.Add('Password=' + ASenha);
  FDConnection1.Params.Add('CharacterSet=utf8mb4');
  FDConnection1.LoginPrompt := False;
  FDConnection1.Open;
end;
```

### PostgreSQL

```pascal
uses FireDAC.Phys.PGDef, FireDAC.Phys.PG;

procedure TdmConexao.ConectarPostgreSQL(
  const AHost: string; APorta: Integer;
  const ABanco, AUsuario, ASenha: string);
begin
  FDConnection1.DriverName := 'PG';
  FDConnection1.Params.Clear;
  FDConnection1.Params.Add('Server='   + AHost);
  FDConnection1.Params.Add('Port='     + APorta.ToString);
  FDConnection1.Params.Add('Database=' + ABanco);
  FDConnection1.Params.Add('User_Name='+ AUsuario);
  FDConnection1.Params.Add('Password=' + ASenha);
  FDConnection1.LoginPrompt := False;
  FDConnection1.Open;
end;
```

### SQLite

```pascal
uses FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite;

procedure TdmConexao.ConectarSQLite(const ACaminhoArquivo: string);
begin
  FDConnection1.DriverName := 'SQLite';
  FDConnection1.Params.Clear;
  FDConnection1.Params.Add('Database=' + ACaminhoArquivo);
  FDConnection1.Params.Add('OpenMode=CreateUTF8');
  FDConnection1.LoginPrompt := False;
  FDConnection1.Open;
end;
```

### Firebird

```pascal
uses FireDAC.Phys.FBDef, FireDAC.Phys.FB;

procedure TdmConexao.ConectarFirebird(
  const AHost, ACaminho, AUsuario, ASenha: string);
begin
  FDConnection1.DriverName := 'FB';
  FDConnection1.Params.Clear;
  // Embedded (sem servidor): Server vazio
  FDConnection1.Params.Add('Server='   + AHost);
  FDConnection1.Params.Add('Database=' + ACaminho);
  FDConnection1.Params.Add('User_Name='+ AUsuario);
  FDConnection1.Params.Add('Password=' + ASenha);
  FDConnection1.Params.Add('CharacterSet=UTF8');
  FDConnection1.LoginPrompt := False;
  FDConnection1.Open;
end;
```

---

## §2 — Definições por arquivo .ini (FDManager)

```ini
; FDConnectionDefs.ini — colocar no diretório do executável
[MINHA_CONEXAO]
DriverID=MSSQL
Server=192.168.1.10
Database=MinhaBD
User_Name=sa
Password=senha123
OSAuthent=No
```

```pascal
uses FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Stan.Intf;

// No .dpr, antes de Application.Run, ou no FormCreate:
procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  // Apontar para o arquivo de definições
  FDManager.ConnectionDefFileName :=
    ExtractFilePath(Application.ExeName) + 'FDConnectionDefs.ini';

  // Conectar pela definição nomeada
  FDConnection1.ConnectionDefName := 'MINHA_CONEXAO';
  FDConnection1.LoginPrompt       := False;
  FDConnection1.Open;
end;
```

---

## §3 — Connection Pooling

```pascal
// Habilitar pool no TFDConnection
procedure TdmConexao.ConfigurarPool;
begin
  FDConnection1.Params.Add('Pooling=True');
  FDConnection1.Params.Add('Pool_MaximumItems=10');
  FDConnection1.Params.Add('Pool_MinimumItems=2');
  FDConnection1.Params.Add('Pool_ExpireTimeout=90000');  // ms
  FDConnection1.Params.Add('Pool_CleanupTimeout=30000'); // ms
end;

// Com pool: Close() não fecha fisicamente — retorna ao pool
// A conexão física só fecha quando o pool expira ou o app termina
```

---

## §4 — Tratamento de erros de conexão

```pascal
uses FireDAC.Stan.Error;

procedure TdmConexao.AbrirComRetry(AMaxTentativas: Integer);
var LTentativa: Integer;
begin
  for LTentativa := 1 to AMaxTentativas do
  begin
    try
      FDConnection1.Open;
      Exit;  // sucesso
    except
      on E: EFDDBEngineException do
      begin
        if LTentativa = AMaxTentativas then
          raise;
        TLogger.Instance.Warn(Format('Tentativa %d falhou: %s', [LTentativa, E.Message]));
        Sleep(2000 * LTentativa);   // backoff exponencial simples
      end;
    end;
  end;
end;

// Verificar se está conectado
function TdmConexao.EstaConectado: Boolean;
begin
  Result := FDConnection1.Connected;
end;

// Reconectar se necessário (antes de executar queries)
procedure TdmConexao.GarantirConexao;
begin
  if not FDConnection1.Connected then
    FDConnection1.Open;
end;
```

---

## §5 — Evento OnLost e reconexão automática

```pascal
procedure TdmConexao.FDConnection1Error(ASender: TObject; AInitiator: IFDStanObject;
  var AException: Exception);
begin
  // Logar mas não exibir dialog ao usuário (conexão em background)
  TLogger.Instance.Error('Erro FireDAC: ' + AException.Message);
end;

procedure TdmConexao.FDConnection1Lost(Sender: TObject);
begin
  // Conexão perdida — tentar reconectar
  TThread.Queue(nil, procedure
  begin
    try
      FDConnection1.Open;
      TLogger.Instance.Info('Reconexão FireDAC bem-sucedida.');
    except
      on E: Exception do
        TLogger.Instance.Error('Falha na reconexão: ' + E.Message);
    end;
  end);
end;
```

---

## §6 — Deployment de drivers (produção)

### SQL Server (ODBC nativo — nenhum arquivo extra em x64)

```
Para Win32: incluir odbccp32.dll (ODBC) — geralmente já no Windows
Para MSSQL nativo: não há DLL extra — usa ODBC do SO
```

### MySQL

```
Copiar para a pasta do executável:
  Win32: libmysql.dll
  Win64: libmysql.dll (x64)
```

### PostgreSQL

```
Copiar para a pasta do executável:
  Win32/Win64: libpq.dll + dependências (libiconv-2.dll, libintl-8.dll)
```

### SQLite

```
SQLite é embutido no FireDAC — nenhuma DLL adicional necessária
```

### Firebird

```
Embedded: fbclient.dll + ib_util.dll + icudt52.dll + icuin52.dll + icuuc52.dll
Cliente servidor: fbclient.dll apenas
```

---

## §7 — Checklist de qualidade — TFDConnection

- [ ] `LoginPrompt := False` para conexão sem dialog
- [ ] Parâmetros sensíveis (senha) carregados de configuração segura, não hardcoded
- [ ] Unidade física do driver incluída nas `uses` (`FireDAC.Phys.MSSQL`, etc.)
- [ ] Pool configurado para aplicações com múltiplas threads
- [ ] `OnError` e `OnLost` tratados — não silenciar exceções
- [ ] Arquivo `.ini` de definições de conexão para ambientes de produção
- [ ] DLLs de driver incluídas no setup do instalador
- [ ] `FDConnection.Close` no `OnDestroy` do DataModule

## Referências cruzadas

- `developer-delphi-firedac-orchestrator` — visão geral e componentes
- `developer-delphi-firedac-queries` — TFDQuery e execução de SQL
- `developer-delphi-firedac-transactions` — controle de transações
