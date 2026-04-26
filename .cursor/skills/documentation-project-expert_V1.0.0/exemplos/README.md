# Exemplos — documentation-project-expert

Exemplos auto-contidos demonstrando as convenções obrigatórias do Projeto v2.0.

## Índice

| Arquivo | Descrição |
|---------|-----------|
| `convenções_basicas.pas` | Interface + implementação com Factory, Fluent e try..finally |
| `convenções_basicas_fpc.pas` | Mesmo exemplo, sintaxe Free Pascal |

---

## convenções_basicas.pas — Delphi (dcc32/dcc64)

```pascal
unit Exemplo.Connection;
{$IFDEF FPC}{$MODE DELPHI}{$ENDIF}

interface

type
  IConexao = interface
    ['{A1B2C3D4-0000-0000-0000-000000000001}']
    function SetHost(const AHost: string): IConexao;
    function SetPort(const APort: Integer): IConexao;
    procedure Conectar;
  end;

  TConexao = class(TInterfacedObject, IConexao)
  private
    FHost: string;
    FPort: Integer;
  public
    class function New: IConexao;
    function SetHost(const AHost: string): IConexao;
    function SetPort(const APort: Integer): IConexao;
    procedure Conectar;
  end;

implementation

class function TConexao.New: IConexao;
begin
  Result := TConexao.Create;
end;

function TConexao.SetHost(const AHost: string): IConexao;
begin
  FHost := AHost;
  Result := Self;
end;

function TConexao.SetPort(const APort: Integer): IConexao;
begin
  FPort := APort;
  Result := Self;
end;

procedure TConexao.Conectar;
begin
  // implementar conexão real aqui
end;

end.
```

**Uso com API Fluente:**

```pascal
var
  LConexao: IConexao;
begin
  LConexao := TConexao.New
    .SetHost('localhost')
    .SetPort(5432);
  LConexao.Conectar;
end;
```

---

## Checklist de verificação

- [ ] Interface prefixada com `I`, classe com `T`
- [ ] Factory via método de classe `New: IInterface`
- [ ] API Fluente: cada `.Metodo()` retorna `Self` como interface
- [ ] Create/Free em try..finally (quando não usar interface contagem de referência)
- [ ] Zero SQL em forms/views
