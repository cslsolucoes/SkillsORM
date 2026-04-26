unit interfaces_fluentes;
{
  EXEMPLO: Interface fluente (Builder pattern) em Delphi
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Metodos que retornam Self (ou interface propria) para encadeamento
    - Builder para SQL query
    - Builder para configuracao de email
    - Interface fluente com factory function New
}

interface

uses
  System.SysUtils, System.Classes;

// ---------------------------------------------------------------------------
// Builder de SQL via interface fluente
// ---------------------------------------------------------------------------
type
  ISqlBuilder = interface
  ['{11223344-5566-7788-99AA-BBCCDDEEFF00}']
    function Select(const ACampos: string): ISqlBuilder;
    function From(const ATabela: string): ISqlBuilder;
    function Where(const ACondicao: string): ISqlBuilder;
    function AndWhere(const ACondicao: string): ISqlBuilder;
    function OrWhere(const ACondicao: string): ISqlBuilder;
    function OrderBy(const ACampos: string; ADesc: Boolean = False): ISqlBuilder;
    function Limit(AMax: Integer): ISqlBuilder;
    function Offset(ASkip: Integer): ISqlBuilder;
    function Build: string;
  end;

function NewSqlBuilder: ISqlBuilder;

// ---------------------------------------------------------------------------
// Builder de email via interface fluente
// ---------------------------------------------------------------------------
type
  IEmailBuilder = interface
  ['{AABBCCDD-1122-3344-5566-778899AABBCC}']
    function De(const AEmail: string): IEmailBuilder;
    function Para(const AEmail: string): IEmailBuilder;
    function CC(const AEmail: string): IEmailBuilder;
    function Assunto(const ATexto: string): IEmailBuilder;
    function Corpo(const ATexto: string): IEmailBuilder;
    function CorpoHtml(const AHtml: string): IEmailBuilder;
    function AnexarArquivo(const ACaminho: string): IEmailBuilder;
    function Enviar: Boolean;
    function Preview: string;
  end;

function NewEmail: IEmailBuilder;

implementation

// ---------------------------------------------------------------------------
// TSqlBuilder
// ---------------------------------------------------------------------------
type
  TSqlBuilder = class(TInterfacedObject, ISqlBuilder)
  private
    FSelect  : string;
    FFrom    : string;
    FWheres  : TStringList;
    FOrderBy : string;
    FLimit   : Integer;
    FOffset  : Integer;
  public
    constructor Create;
    destructor Destroy; override;

    function Select(const ACampos: string): ISqlBuilder;
    function From(const ATabela: string): ISqlBuilder;
    function Where(const ACondicao: string): ISqlBuilder;
    function AndWhere(const ACondicao: string): ISqlBuilder;
    function OrWhere(const ACondicao: string): ISqlBuilder;
    function OrderBy(const ACampos: string; ADesc: Boolean = False): ISqlBuilder;
    function Limit(AMax: Integer): ISqlBuilder;
    function Offset(ASkip: Integer): ISqlBuilder;
    function Build: string;
  end;

function NewSqlBuilder: ISqlBuilder;
begin
  Result := TSqlBuilder.Create;
end;

constructor TSqlBuilder.Create;
begin
  inherited Create;
  FSelect  := '*';
  FLimit   := -1;
  FOffset  := 0;
  FWheres  := TStringList.Create;
end;

destructor TSqlBuilder.Destroy;
begin
  FWheres.Free;
  inherited;
end;

function TSqlBuilder.Select(const ACampos: string): ISqlBuilder;
begin
  FSelect := ACampos;
  Result  := Self;
end;

function TSqlBuilder.From(const ATabela: string): ISqlBuilder;
begin
  FFrom  := ATabela;
  Result := Self;
end;

function TSqlBuilder.Where(const ACondicao: string): ISqlBuilder;
begin
  FWheres.Clear;
  FWheres.Add(ACondicao);
  Result := Self;
end;

function TSqlBuilder.AndWhere(const ACondicao: string): ISqlBuilder;
begin
  FWheres.Add('AND ' + ACondicao);
  Result := Self;
end;

function TSqlBuilder.OrWhere(const ACondicao: string): ISqlBuilder;
begin
  FWheres.Add('OR ' + ACondicao);
  Result := Self;
end;

function TSqlBuilder.OrderBy(const ACampos: string; ADesc: Boolean): ISqlBuilder;
begin
  FOrderBy := ACampos;
  if ADesc then FOrderBy := FOrderBy + ' DESC';
  Result := Self;
end;

function TSqlBuilder.Limit(AMax: Integer): ISqlBuilder;
begin
  FLimit := AMax;
  Result := Self;
end;

function TSqlBuilder.Offset(ASkip: Integer): ISqlBuilder;
begin
  FOffset := ASkip;
  Result := Self;
end;

function TSqlBuilder.Build: string;
var
  SB: TStringBuilder;
  I : Integer;
begin
  SB := TStringBuilder.Create;
  try
    SB.Append('SELECT ').Append(FSelect);
    SB.Append(' FROM ').Append(FFrom);

    if FWheres.Count > 0 then
    begin
      SB.Append(' WHERE ').Append(FWheres[0]);
      for I := 1 to FWheres.Count - 1 do
        SB.Append(' ').Append(FWheres[I]);
    end;

    if not FOrderBy.IsEmpty then
      SB.Append(' ORDER BY ').Append(FOrderBy);

    if FLimit > 0 then
      SB.Append(' LIMIT ').Append(FLimit.ToString);

    if FOffset > 0 then
      SB.Append(' OFFSET ').Append(FOffset.ToString);

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

// ---------------------------------------------------------------------------
// TEmailBuilder
// ---------------------------------------------------------------------------
type
  TEmailBuilder = class(TInterfacedObject, IEmailBuilder)
  private
    FDe     : string;
    FPara   : TStringList;
    FCC     : TStringList;
    FAssunto: string;
    FCorpo  : string;
    FHtml   : string;
    FAnexos : TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    function De(const AEmail: string): IEmailBuilder;
    function Para(const AEmail: string): IEmailBuilder;
    function CC(const AEmail: string): IEmailBuilder;
    function Assunto(const ATexto: string): IEmailBuilder;
    function Corpo(const ATexto: string): IEmailBuilder;
    function CorpoHtml(const AHtml: string): IEmailBuilder;
    function AnexarArquivo(const ACaminho: string): IEmailBuilder;
    function Enviar: Boolean;
    function Preview: string;
  end;

function NewEmail: IEmailBuilder;
begin
  Result := TEmailBuilder.Create;
end;

constructor TEmailBuilder.Create;
begin
  inherited Create;
  FPara   := TStringList.Create;
  FCC     := TStringList.Create;
  FAnexos := TStringList.Create;
end;

destructor TEmailBuilder.Destroy;
begin
  FPara.Free; FCC.Free; FAnexos.Free;
  inherited;
end;

function TEmailBuilder.De(const AEmail: string): IEmailBuilder;
begin FDe := AEmail; Result := Self; end;

function TEmailBuilder.Para(const AEmail: string): IEmailBuilder;
begin FPara.Add(AEmail); Result := Self; end;

function TEmailBuilder.CC(const AEmail: string): IEmailBuilder;
begin FCC.Add(AEmail); Result := Self; end;

function TEmailBuilder.Assunto(const ATexto: string): IEmailBuilder;
begin FAssunto := ATexto; Result := Self; end;

function TEmailBuilder.Corpo(const ATexto: string): IEmailBuilder;
begin FCorpo := ATexto; Result := Self; end;

function TEmailBuilder.CorpoHtml(const AHtml: string): IEmailBuilder;
begin FHtml := AHtml; Result := Self; end;

function TEmailBuilder.AnexarArquivo(const ACaminho: string): IEmailBuilder;
begin FAnexos.Add(ACaminho); Result := Self; end;

function TEmailBuilder.Enviar: Boolean;
begin
  // FSmtpClient.Send(FDe, FPara, FAssunto, FCorpo);
  Writeln('Email enviado para: ', FPara.CommaText);
  Result := True;
end;

function TEmailBuilder.Preview: string;
begin
  Result := Format('De: %s | Para: %s | Assunto: %s | Corpo: %s',
    [FDe, FPara.CommaText, FAssunto, Copy(FCorpo, 1, 50)]);
end;

// ---------------------------------------------------------------------------
// USO:
//
//   var Sql := NewSqlBuilder
//     .Select('id, nome, email')
//     .From('clientes')
//     .Where('ativo = 1')
//     .AndWhere('cidade = :cidade')
//     .OrderBy('nome')
//     .Limit(20)
//     .Offset(40)
//     .Build;
//
//   NewEmail
//     .De('sistema@empresa.com')
//     .Para('cliente@email.com')
//     .CC('gerente@empresa.com')
//     .Assunto('Confirmacao de pedido')
//     .Corpo('Seu pedido foi confirmado.')
//     .AnexarArquivo('C:\nota.pdf')
//     .Enviar;
// ---------------------------------------------------------------------------

end.
