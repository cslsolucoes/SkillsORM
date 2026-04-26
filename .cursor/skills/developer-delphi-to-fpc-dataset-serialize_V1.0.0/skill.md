---
name: developer-delphi-to-fpc-dataset-serialize
description: Serialização JSON↔DataSet com dataset-serialize em Delphi/FPC. Cobre ToJSONObject, ToJSONArray, LoadFromJSON, MergeFromJSON, ValidateJSON, SaveStructure/LoadStructure, TDataSetSerializeConfig (formato de data, CaseNameDefinition), nested JSON (master-detail) e filtro de campos. Fonte canônica: app/package/docs/pacotes/dataset-serialize.md.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-dataset-serialize

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Conversão bidirecional entre `TDataSet` e JSON usando `dataset-serialize`. Inclui exportação, importação, validação, estrutura de campos e configuração global.

## When to use

- Exportar DataSet para JSON (um registo ou todos)
- Importar JSON para DataSet (LoadFromJSON, MergeFromJSON)
- Validar JSON contra campos obrigatórios do DataSet
- Persistir/restaurar estrutura de campos (SaveStructure/LoadStructure)
- Configurar formato de data, case de nomes de campo
- Master-detail (nested JSON com TDataSetField)
- Filtrar campos no export

## When NOT to use

- Adaptador DataSet via RESTRequest4Delphi → `developer-delphi-to-fpc-http-client-rest`
- Resposta JSON em handler Horse → usar `ToJSONArray` diretamente no handler

## Documento canônico

`app/package/docs/pacotes/dataset-serialize.md`

---

## TDataSetSerializeHelper — helper de TDataSet

| Método | Descrição |
| --- | --- |
| `ToJSONObject(...)` | Registo atual → TJSONObject |
| `ToJSONObjectString(...)` | Registo atual → string JSON |
| `ToJSONArray(...)` | Todos os registos → TJSONArray |
| `ToJSONArrayString(...)` | Todos os registos → string JSON |
| `SaveStructure` | Estrutura de campos → TJSONArray |
| `LoadStructure(json, own)` | Cria campos a partir de JSON |
| `ValidateJSON(json)` | Valida campos obrigatórios → TJSONArray de erros |
| `LoadFromJSON(json)` | Importa JSON para o DataSet |
| `MergeFromJSON(json)` | Mescla JSON sem limpar dados existentes |

---

## TDataSetSerializeConfig — configuração global

| Método | Descrição |
| --- | --- |
| `GetInstance` | Instância singleton |
| `Export.DateTimeFormat(fmt)` | Formato de data/hora no export |
| `Export.DateFormat(fmt)` | Formato de data no export |
| `Export.TimeFormat(fmt)` | Formato de hora no export |
| `Import.DateTimeFormat(fmt)` | Formato esperado no import |
| `CaseNameDefinition(tipo)` | Case dos nomes de campo (cndLower, cndUpper…) |

---

## Exemplos

### Getting started

```pascal
uses DataSet.Serialize;
```

### Export: registo atual e lista

```pascal
var
  LJSONObject: TJSONObject;
  LJSONArray: TJSONArray;
begin
  LJSONObject := qrySamples.ToJSONObject(); // registo atual
  LJSONArray  := qrySamples.ToJSONArray();  // todos os registos
end;
```

### Export para string (resposta HTTP)

```delphi
// Em handler Horse:
var LJson: string;
LJson := qryUsers.ToJSONArrayString;
Res.Send(LJson);

// Ou com TJSONArray:
var LArr: TJSONArray;
LArr := qryUsers.ToJSONArray;
Res.Send<TJSONArray>(LArr); // Horse liberta o objeto
```

### Export com filtro de campos

```delphi
// Apenas 'id' e 'name'
LJSONArray := qrySamples.ToJSONArray(['id', 'name']);
```

### Export com opções avançadas

```delphi
// Apenas registos editados, com sub-datasets, sem BLOB em base64
LObj := qryUsers.ToJSONObject(True, True, True, False);
```

### Import: LoadFromJSON

```pascal
// Array de objetos
qrySamples.LoadFromJSON('[{"firstName":"Vinicius","country":"Brazil"}]');

// Objeto único
qrySamples.LoadFromJSON('{"firstName":"Vinicius","country":"Brazil"}');

// A partir de TJSONArray
var LArr: TJSONArray;
LArr := TJSONArray.ParseJSONValue('[{"name":"Ana"},{"name":"Rui"}]') as TJSONArray;
try
  qrySamples.LoadFromJSON(LArr);
finally
  LArr.Free;
end;
```

### Iterar após LoadFromJSON

```delphi
qrySamples.LoadFromJSON('[{"name":"Ana"},{"name":"Rui"}]');
qrySamples.First;
while not qrySamples.Eof do
begin
  ShowMessage(qrySamples.FieldByName('name').AsString);
  qrySamples.Next;
end;
```

### MergeFromJSON — mesclar sem limpar

```delphi
// Adiciona/actualiza sem limpar registos existentes
qryUsers.MergeFromJSON('[{"id":5,"name":"Eva"}]');
```

### ValidateJSON — campos obrigatórios

```pascal
var LErrors: TJSONArray;
begin
  LErrors := qrySamples.ValidateJSON('{"country":"Brazil"}');
  try
    if LErrors.Count > 0 then
      raise Exception.Create('Campos em falta: ' + LErrors.ToJSON);
  finally
    LErrors.Free;
  end;
end;
```

### SaveStructure / LoadStructure

```pascal
var LStructure: TJSONArray;
begin
  // Guardar estrutura
  LStructure := qrySamples.SaveStructure;
  try
    TFile.WriteAllText('structure.json', LStructure.ToJSON);
  finally
    LStructure.Free;
  end;

  // Restaurar estrutura
  LStructure := TJSONArray.ParseJSONValue(
    TFile.ReadAllText('structure.json')
  ) as TJSONArray;
  qrySamples.LoadStructure(LStructure, True); // True = liberta LStructure
end;
```

### Master-detail (nested JSON)

```pascal
var LJSONObject: TJSONObject;
begin
  // qryPedidos tem TDataSetField 'itens' → qryItens
  LJSONObject := qryPedidos.ToJSONObject(True);
  // Resultado: {"id":1,"data":"2026-04-12","itens":[...]}
end;
```

### Configuração ISO 8601 (recomendada GestorERP)

```delphi
uses DataSet.Serialize.Config;

TDataSetSerializeConfig.GetInstance
  .Export
    .DateTimeFormat('yyyy-MM-dd"T"HH:mm:ss')
    .DateFormat('yyyy-MM-dd')
    .TimeFormat('HH:mm:ss')
  .&End
  .Import
    .DateTimeFormat('yyyy-MM-dd"T"HH:mm:ss')
    .DateFormat('yyyy-MM-dd')
  .&End;
```

### CaseNameDefinition — nomes lowercase

```delphi
TDataSetSerializeConfig.GetInstance
  .CaseNameDefinition(TCaseNameDefinition.cndLower);
// Campo USER_ID exporta como 'user_id'
```

---

## Módulos internos

| Unit | Responsabilidade |
| --- | --- |
| `DataSet.Serialize.pas` | Helper principal (extension de TDataSet) |
| `DataSet.Serialize.Export.pas` | Lógica de export |
| `DataSet.Serialize.Import.pas` | Lógica de import |
| `DataSet.Serialize.Config.pas` | Configuração global |
| `DataSet.Serialize.Utils.pas` | Utilitários internos |
| `DataSet.Serialize.Consts.pas` | Constantes |
| `DataSet.Serialize.Language.pas` | Internacionalização |
| `DataSet.Serialize.UpdatedStatus.pas` | Controlo de registos editados |

---

## Notas GestorERP

- Formato de data adoptado: ISO 8601 (`yyyy-MM-dd"T"HH:mm:ss`)
- Configurar `TDataSetSerializeConfig` no DPR antes de qualquer request
- Campos calculados exportam por defeito — usar `ToJSONArray(Fields)` para filtrar
- Compatível com Delphi e FPC

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill de serialização JSON↔DataSet.
