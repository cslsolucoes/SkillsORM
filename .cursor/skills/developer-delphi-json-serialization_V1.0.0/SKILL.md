---
name: developer-delphi-json-serialization
description: >
  JSON em Delphi: System.JSON, TJSONObject, TJSONArray, TJSONValue, parsing,
  serialização/desserialização de objetos, REST.Json (TJson), JSON Data Binding Wizard,
  TFDJSONDataSets, leitura de arquivos JSON, geração de JSON para APIs REST.
  Ativar quando o usuário mencionar: JSON Delphi, TJSONObject, TJSONArray,
  TJSONValue, serializar JSON, desserializar JSON, parsear JSON, REST.Json,
  TJson, JSON para objeto, objeto para JSON, API REST JSON Delphi, TFDJSONDataSets,
  JSON Data Binding, System.JSON.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-json-serialization

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | REST / Serialização |

## Responsabilidade única

Criar, parsear, serializar e desserializar JSON em Delphi usando System.JSON e
REST.Json. Cobre leitura/escrita de arquivos JSON, integração com APIs REST e
serialização de datasets FireDAC.

## When to use

- Parsear string JSON recebida de API REST
- Serializar objetos/DTOs para JSON (enviar para API)
- Ler e escrever arquivos `.json` de configuração
- Converter TFDQuery/TDataSet para JSON e vice-versa
- Mapear JSON com `[JSONName]` e `[JSONSerialize]` attributes

## When NOT to use

- HTTP GET/POST em si → `developer-delphi-indy-http`
- Parsing XML → `System.XMLDoc` (fora do escopo desta skill)

---

## §1 — System.JSON — parsing básico

```pascal
uses System.JSON;

// Parsear JSON string
procedure TfrmPrincipal.ParsearJSON(const AJson: string);
var
  LRoot: TJSONValue;
  LObj: TJSONObject;
  LArr: TJSONArray;
  LItem: TJSONValue;
begin
  LRoot := TJSONObject.ParseJSONValue(AJson);
  if not Assigned(LRoot) then
    raise EJSONException.Create('JSON inválido');
  try
    LObj := LRoot as TJSONObject;

    // Ler campo string
    var LNome   := LObj.GetValue<string>('nome');
    var LIdade  := LObj.GetValue<Integer>('idade');
    var LAtivo  := LObj.GetValue<Boolean>('ativo');

    // Ler campo aninhado
    var LCidade := LObj.GetValue<TJSONObject>('endereco')
                       .GetValue<string>('cidade');

    // Ler array
    LArr := LObj.GetValue<TJSONArray>('telefones');
    for LItem in LArr do
      Memo1.Lines.Add(LItem.Value);

  finally
    LRoot.Free;
  end;
end;

// Verificar existência de campo antes de ler
function TfrmPrincipal.LerCampoSeguro(AObj: TJSONObject;
  const ACampo: string): string;
var LVal: TJSONValue;
begin
  LVal := AObj.FindValue(ACampo);
  if Assigned(LVal) and not (LVal is TJSONNull) then
    Result := LVal.Value
  else
    Result := '';
end;
```

---

## §2 — Construção de JSON

```pascal
uses System.JSON;

// Construir TJSONObject
function TdmPrincipal.ClienteParaJSON(ACliente: TClienteDTO): string;
var
  LObj: TJSONObject;
  LEnd: TJSONObject;
  LFones: TJSONArray;
begin
  LObj := TJSONObject.Create;
  try
    LObj.AddPair('id',     TJSONNumber.Create(ACliente.Id));
    LObj.AddPair('nome',   ACliente.Nome);
    LObj.AddPair('ativo',  TJSONBool.Create(ACliente.Ativo));

    // Objeto aninhado
    LEnd := TJSONObject.Create;
    LEnd.AddPair('rua',    ACliente.Rua);
    LEnd.AddPair('cidade', ACliente.Cidade);
    LEnd.AddPair('cep',    ACliente.CEP);
    LObj.AddPair('endereco', LEnd);

    // Array
    LFones := TJSONArray.Create;
    for var LFone in ACliente.Telefones do
      LFones.Add(LFone);
    LObj.AddPair('telefones', LFones);

    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;
```

---

## §3 — REST.Json — serialização automática

```pascal
uses REST.Json, REST.Json.Types;

// DTO com atributos de mapeamento
type
  TEnderecoDTO = class
  public
    [JSONName('rua')]    Rua: string;
    [JSONName('cidade')] Cidade: string;
    [JSONName('cep')]    CEP: string;
  end;

  TClienteDTO = class
  public
    [JSONName('id')]       Id: Integer;
    [JSONName('nome')]     Nome: string;
    [JSONName('ativo')]    Ativo: Boolean;
    [JSONName('endereco')] Endereco: TEnderecoDTO;
    [JSONMarshalled(False)] // não incluir no JSON
    SenhaInterna: string;
    destructor Destroy; override;
  end;

destructor TClienteDTO.Destroy;
begin
  Endereco.Free;
  inherited;
end;

// Serializar objeto → JSON
function TServico.Serializar(ACliente: TClienteDTO): string;
begin
  Result := TJson.ObjectToJsonString(ACliente);
end;

// Desserializar JSON → objeto
function TServico.Desserializar(const AJson: string): TClienteDTO;
begin
  Result := TJson.JsonToObject<TClienteDTO>(AJson);
  // Caller é responsável por liberar o objeto retornado
end;

// Array de objetos
function TServico.DeserializarLista(const AJson: string): TArray<TClienteDTO>;
var LArr: TJSONArray;
begin
  LArr := TJSONObject.ParseJSONValue(AJson) as TJSONArray;
  try
    SetLength(Result, LArr.Count);
    for var I := 0 to LArr.Count - 1 do
      Result[I] := TJson.JsonToObject<TClienteDTO>(LArr.Items[I].ToJSON);
  finally
    LArr.Free;
  end;
end;
```

---

## §4 — Leitura e escrita de arquivo JSON

```pascal
uses System.JSON, System.IOUtils;

// Ler arquivo JSON
function TConfiguracoes.Carregar(const ACaminho: string): TJSONObject;
var LConteudo: string;
begin
  if not TFile.Exists(ACaminho) then
    raise EFileNotFoundException.CreateFmt('Arquivo não encontrado: %s', [ACaminho]);

  LConteudo := TFile.ReadAllText(ACaminho, TEncoding.UTF8);
  Result := TJSONObject.ParseJSONValue(LConteudo) as TJSONObject;
  // Caller libera o objeto
end;

// Salvar arquivo JSON (com indentação legível)
procedure TConfiguracoes.Salvar(AObj: TJSONObject; const ACaminho: string);
var LJson: string;
begin
  LJson := AObj.Format(2);   // 2 espaços de indentação
  TFile.WriteAllText(ACaminho, LJson, TEncoding.UTF8);
end;

// Exemplo de uso
procedure TfrmPrincipal.CarregarConfig;
var LConfig: TJSONObject;
begin
  LConfig := TConfiguracoes.Instance.Carregar(
    ExtractFilePath(Application.ExeName) + 'config.json');
  try
    edtServidor.Text := LConfig.GetValue<string>('servidor');
    edtBanco.Text    := LConfig.GetValue<string>('banco');
  finally
    LConfig.Free;
  end;
end;
```

---

## §5 — TFDJSONDataSets — datasets para JSON

```pascal
uses FireDAC.Comp.Client, FireDAC.Stan.StorageJSON, FireDAC.Stan.StorageBin;

// Serializar TFDQuery para JSON (útil para cache ou transferência)
function TdmPrincipal.DataSetParaJSON(AQuery: TFDQuery): string;
var LMemo: TStringStream;
begin
  LMemo := TStringStream.Create('', TEncoding.UTF8);
  try
    AQuery.SaveToStream(LMemo, sfJSON);
    Result := LMemo.DataString;
  finally
    LMemo.Free;
  end;
end;

// Restaurar dataset do JSON
procedure TdmPrincipal.JSONParaDataSet(const AJson: string; ADest: TFDMemTable);
var LStream: TStringStream;
begin
  LStream := TStringStream.Create(AJson, TEncoding.UTF8);
  try
    ADest.Close;
    ADest.LoadFromStream(LStream, sfJSON);
    ADest.Open;
  finally
    LStream.Free;
  end;
end;
```

---

## §6 — Tratamento de erros de parsing

```pascal
uses System.JSON, System.SysUtils;

function TServico.ParsearSeguro(const AJson: string;
  out AObj: TJSONObject): Boolean;
var LVal: TJSONValue;
begin
  Result := False;
  AObj   := nil;
  if AJson.Trim.IsEmpty then Exit;
  try
    LVal := TJSONObject.ParseJSONValue(AJson);
    if Assigned(LVal) and (LVal is TJSONObject) then
    begin
      AObj   := LVal as TJSONObject;
      Result := True;
    end
    else
      LVal.Free;
  except
    on E: EJSONException do
      TLogger.Instance.Warn('JSON inválido: ' + E.Message);
  end;
end;
```

---

## §7 — Checklist de qualidade — JSON

- [ ] Sempre liberar `TJSONValue` / `TJSONObject` retornado por `ParseJSONValue`
- [ ] Usar `FindValue` (não `GetValue`) quando o campo pode ser nulo/ausente
- [ ] `[JSONMarshalled(False)]` em campos sensíveis não serializáveis
- [ ] `TEncoding.UTF8` em leitura e escrita de arquivos JSON
- [ ] `TJson.JsonToObject<T>` — documentar que o caller libera o objeto retornado
- [ ] Validar `ParseJSONValue <> nil` antes de fazer cast
- [ ] Para datasets grandes, preferir serialização binária (`sfBinary`) a JSON

## Referências cruzadas

- `developer-delphi-indy-http` — enviar/receber JSON via HTTP
- `developer-delphi-firedac-queries` — TFDMemTable e datasets
