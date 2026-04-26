unit TEMPLATE_record_dto;
{
  TEMPLATE: Record como DTO (Data Transfer Object)
  Uso: copie e renomeie. Substitua ENTIDADE.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.JSON;

// ---------------------------------------------------------------------------
// DTO imutavel como record
// Convencoes:
//   - Campos publicos (sem getter/setter) — record e value type
//   - Factory method: class function Novo(...)
//   - Validacao: function EhValido: Boolean
//   - Serializacao: function ToJSON / class function FromJSON
//   - Conversao: class function FromDB(ADataSet: TDataSet)
// ---------------------------------------------------------------------------
type
  TEntidadeDTO = record
  public
    // --- Campos ---
    Codigo    : Integer;
    Nome      : string;
    Email     : string;
    DataCriacao: TDateTime;

    // --- Factory methods ---
    class function Novo(ACodigo: Integer; const ANome, AEmail: string): TEntidadeDTO; static;
    class function Vazio: TEntidadeDTO; static;

    // --- Validacao ---
    function EhValido: Boolean;
    function MensagemErro: string;

    // --- Serializacao ---
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject): TEntidadeDTO; static;

    // --- Utilitarios ---
    function ToString: string;
    function EhNovo: Boolean; // Codigo = 0 = nao persistido
  end;

implementation

class function TEntidadeDTO.Novo(ACodigo: Integer;
  const ANome, AEmail: string): TEntidadeDTO;
begin
  Result.Codigo     := ACodigo;
  Result.Nome       := ANome;
  Result.Email      := AEmail;
  Result.DataCriacao := Now;
end;

class function TEntidadeDTO.Vazio: TEntidadeDTO;
begin
  Result.Codigo      := 0;
  Result.Nome        := '';
  Result.Email       := '';
  Result.DataCriacao := 0;
end;

function TEntidadeDTO.EhValido: Boolean;
begin
  Result := MensagemErro.IsEmpty;
end;

function TEntidadeDTO.MensagemErro: string;
begin
  Result := '';
  if Nome.Trim.IsEmpty then
    Result := Result + 'Nome e obrigatorio.' + sLineBreak;
  if Email.Trim.IsEmpty then
    Result := Result + 'E-mail e obrigatorio.' + sLineBreak;
  if (not Email.IsEmpty) and (Pos('@', Email) = 0) then
    Result := Result + 'E-mail invalido.' + sLineBreak;
end;

function TEntidadeDTO.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('codigo',     TJSONNumber.Create(Codigo));
  Result.AddPair('nome',       Nome);
  Result.AddPair('email',      Email);
  Result.AddPair('dataCriacao', DateTimeToStr(DataCriacao));
end;

class function TEntidadeDTO.FromJSON(AJson: TJSONObject): TEntidadeDTO;
begin
  Result.Codigo      := AJson.GetValue<Integer>('codigo', 0);
  Result.Nome        := AJson.GetValue<string>('nome', '');
  Result.Email       := AJson.GetValue<string>('email', '');
  Result.DataCriacao := StrToDateTimeDef(
    AJson.GetValue<string>('dataCriacao', ''), 0);
end;

function TEntidadeDTO.ToString: string;
begin
  Result := Format('[%d] %s <%s>', [Codigo, Nome, Email]);
end;

function TEntidadeDTO.EhNovo: Boolean;
begin
  Result := Codigo = 0;
end;

// ---------------------------------------------------------------------------
// USO:
//   var DTO := TEntidadeDTO.Novo(0, 'Maria', 'maria@email.com');
//   if DTO.EhValido then
//     FService.Salvar(DTO)
//   else
//     ShowMessage(DTO.MensagemErro);
//
//   // Receber de JSON (REST):
//   var DTO2 := TEntidadeDTO.FromJSON(JsonResponse);
//
//   // Enviar para API:
//   var J := DTO.ToJSON;
//   try
//     FHttp.Post('/entidade', J.ToJSON);
//   finally
//     J.Free;
//   end;
// ---------------------------------------------------------------------------

end.
