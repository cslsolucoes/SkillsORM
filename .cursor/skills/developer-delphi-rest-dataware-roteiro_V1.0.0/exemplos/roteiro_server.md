---
description: "Exemplos de configuração de servidor REST — REST DataWare"
alwaysApply: false
---

# Roteiro — Servidor REST (REST DataWare)

> Fonte canônica: `app/modules/REST-DataWare/Documentation/Arquitetura/Arquitetura_RESTDataWare_V2.1.md`

## 1. Servidor básico com Indy (configuração mínima)

```pascal
uses uRESTDWIdBase, uRESTDWPoolerDB;

type
  TServerForm = class(TForm)
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    RESTDWIdBase1: TRESTDWIdBase;
  end;

procedure TServerForm.FormCreate(Sender: TObject);
begin
  // Configurar pool de conexões
  RESTDWPoolerDB1.DataBase     := 'empresa';
  RESTDWPoolerDB1.UserName     := 'admin';
  RESTDWPoolerDB1.Password     := 'senha';
  RESTDWPoolerDB1.ServerName   := 'localhost';

  // Associar servidor ao pool
  RESTDWIdBase1.RESTDWPoolerDB := RESTDWPoolerDB1;
  RESTDWIdBase1.Port           := 8082;
  RESTDWIdBase1.Active         := True;
end;
```

## 2. Servidor com SSL/HTTPS

```pascal
uses uRESTDWIdBase, uRESTDWPoolerDB, IdSSLOpenSSL;

procedure TServerForm.ConfigurarSSL;
begin
  // SSL Handler para o servidor Indy
  RESTDWIdBase1.SSLIOHandler.CertFile  := 'server.pem';
  RESTDWIdBase1.SSLIOHandler.KeyFile   := 'server.key';
  RESTDWIdBase1.SSLIOHandler.RootCertFile := 'ca.pem';
  RESTDWIdBase1.SSLIOHandler.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];

  RESTDWIdBase1.Port   := 8443;
  RESTDWIdBase1.Active := True;
end;
```

## 3. Pool de conexões com tamanho configurável

```pascal
procedure TServerForm.ConfigurarPool;
begin
  RESTDWPoolerDB1.DataBase       := 'empresa';
  RESTDWPoolerDB1.UserName       := 'admin';
  RESTDWPoolerDB1.Password       := 'senha';
  RESTDWPoolerDB1.ServerName     := 'db.empresa.com';
  RESTDWPoolerDB1.Port           := 5432;      // PostgreSQL
  RESTDWPoolerDB1.MaxConnections := 20;        // máximo de conexões no pool
  RESTDWPoolerDB1.MinConnections := 5;         // mínimo (pré-alocadas)
  RESTDWPoolerDB1.TimeOut        := 30000;     // 30 segundos (ms)
  RESTDWPoolerDB1.Active         := True;
end;
```

## 4. Tratamento de eventos do servidor

```pascal
procedure TServerForm.RESTDWIdBase1BeforeRESTRequest(
  Sender: TObject;
  var RequestType: TRESTRequestType;
  var RouteName: string;
  var Params: TRESTDWParams;
  var ConnectionParams: TRESTDWConnectionParams);
begin
  // Executado antes de processar a requisição REST
  // Pode ser usado para log, autenticação adicional, etc.
end;

procedure TServerForm.RESTDWIdBase1AfterRESTRequest(
  Sender: TObject;
  var RequestType: TRESTRequestType;
  var RouteName: string;
  var ResultJSON: string;
  var StatusCode: Integer);
begin
  // Executado após processar a requisição REST
  // Pode ser usado para log de resposta, métricas, etc.
end;
```

## 5. Verificar se servidor está ativo

```pascal
procedure TServerForm.BtnStatusClick(Sender: TObject);
begin
  if RESTDWIdBase1.Active then
    ShowMessage('Servidor ativo na porta ' + IntToStr(RESTDWIdBase1.Port))
  else
    ShowMessage('Servidor inativo');
end;

procedure TServerForm.BtnPararClick(Sender: TObject);
begin
  RESTDWIdBase1.Active := False;
  ShowMessage('Servidor parado');
end;
```
