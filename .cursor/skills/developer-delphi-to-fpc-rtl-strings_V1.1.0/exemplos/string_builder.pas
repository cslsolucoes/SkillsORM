unit string_builder;
{
  TStringBuilder — concatenações performáticas, buffer interno mutável
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils;

procedure DemoStringBuilderBasico;
procedure DemoStringBuilderPerformance;
procedure DemoStringBuilderEdit;
procedure DemoBuildCSV;
procedure DemoBuildHTML;

implementation

// ---------------------------------------------------------------------------
// DemoStringBuilderBasico — criação, Append, AppendLine, ToString
// ---------------------------------------------------------------------------

procedure DemoStringBuilderBasico;
var SB: TStringBuilder;
begin
  SB := TStringBuilder.Create;
  try
    // Append — retorna Self para encadeamento
    SB.Append('Nome: ').Append('Alice').AppendLine;
    SB.Append('Idade: ').Append(30).AppendLine;
    SB.Append('Saldo: R$').Append(1500.50, 'N2').AppendLine;
    SB.Append('Ativo: ').Append(True).AppendLine;

    Writeln(SB.ToString);

    // Propriedades
    Writeln('Length: ', SB.Length);
    Writeln('Capacity: ', SB.Capacity);  // pode ser maior que Length

    // Limpar para reutilizar (sem realocar)
    SB.Clear;
    Writeln('Após Clear, Length=', SB.Length);
    Writeln('Capacity ainda: ', SB.Capacity);
  finally
    SB.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoStringBuilderPerformance — por que usar em loops
// ---------------------------------------------------------------------------

procedure DemoStringBuilderPerformance;
const N = 10000;
var SB:    TStringBuilder;
    I:     Integer;
    Resultado: string;
begin
  // COM TStringBuilder — O(n), sem realocação excessiva
  SB := TStringBuilder.Create(N * 10);  // capacidade inicial estimada
  try
    for I := 1 to N do
    begin
      SB.Append('item');
      SB.Append(I);
      if I < N then SB.Append(',');
    end;
    Resultado := SB.ToString;
    Writeln('TStringBuilder: ', Length(Resultado), ' chars (OK)');
  finally
    SB.Free;
  end;

  // SEM TStringBuilder — O(n²), cada := cria nova string
  // var S: string := '';
  // for I := 1 to N do
  //   S := S + 'item' + IntToStr(I) + ',';  // lento para N grande!

  // AppendFormat — como Format mas no SB
  SB := TStringBuilder.Create;
  try
    for I := 1 to 5 do
      SB.AppendFormat('[%d] item %s'#13#10, [I, 'valor_' + I.ToString]);
    Writeln(SB.ToString);
  finally
    SB.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoStringBuilderEdit — Insert, Delete, Replace, operações in-place
// ---------------------------------------------------------------------------

procedure DemoStringBuilderEdit;
var SB: TStringBuilder;
begin
  SB := TStringBuilder.Create('Olá, Delphi!');
  try
    Writeln('Inicial: ', SB.ToString);

    // Insert na posição (base 0)
    SB.Insert(4, 'Mundo e ');
    Writeln('Após Insert(4): ', SB.ToString);
    // 'Olá, Mundo e Delphi!'

    // Remove — posição base 0, comprimento
    SB.Remove(4, 9);  // remove 'Mundo e '
    Writeln('Após Remove(4,9): ', SB.ToString);

    // Replace — substitui todas as ocorrências
    SB.Replace('Delphi', 'Pascal');
    Writeln('Após Replace: ', SB.ToString);

    // Replace com índice e comprimento (substitui só no trecho)
    SB.Replace('!', '?', 0, SB.Length);
    Writeln('Após Replace "!": ', SB.ToString);

    // Acesso por índice (leitura/escrita)
    Writeln('Chars[0]: ', SB.Chars[0]);
    SB.Chars[0] := 'o';  // minúscula
    Writeln('Após Chars[0]:="o": ', SB.ToString);

    // Append de caractere
    SB.Append(Char('!'));
    Writeln('Após Append char: ', SB.ToString);

    // Length pode ser reduzida para truncar
    SB.Length := 5;
    Writeln('Após Length:=5: ', SB.ToString);
  finally
    SB.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoBuildCSV — gerar CSV com TStringBuilder
// ---------------------------------------------------------------------------

type
  TLinha = record
    Id:    Integer;
    Nome:  string;
    Email: string;
    Valor: Currency;
  end;

procedure DemoBuildCSV;
var SB:    TStringBuilder;
    Dados: array[0..3] of TLinha;
    L:     TLinha;
    S:     string;
begin
  Dados[0].Id := 1; Dados[0].Nome := 'Alice';  Dados[0].Email := 'alice@ex.com';  Dados[0].Valor := 1500;
  Dados[1].Id := 2; Dados[1].Nome := 'Bob';    Dados[1].Email := 'bob@ex.com';    Dados[1].Valor := 2300;
  Dados[2].Id := 3; Dados[2].Nome := 'Carol';  Dados[2].Email := 'carol@ex.com';  Dados[2].Valor := 800;
  Dados[3].Id := 4; Dados[3].Nome := 'Dave';   Dados[3].Email := 'dave@ex.com';   Dados[3].Valor := 4100;

  SB := TStringBuilder.Create;
  try
    // Cabeçalho
    SB.AppendLine('Id,Nome,Email,Valor');

    // Linhas
    for L in Dados do
    begin
      SB.Append(L.Id).Append(',');
      // Aspas em campos que podem ter vírgula
      if L.Nome.Contains(',') then
        SB.Append('"').Append(L.Nome).Append('"')
      else
        SB.Append(L.Nome);
      SB.Append(',');
      SB.Append(L.Email).Append(',');
      SB.AppendFormat('%.2f', [L.Valor]);
      SB.AppendLine;
    end;

    S := SB.ToString;
    Writeln('--- CSV ---');
    Writeln(S);
    Writeln('Total chars: ', Length(S));
  finally
    SB.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoBuildHTML — gerar HTML com TStringBuilder
// ---------------------------------------------------------------------------

procedure DemoBuildHTML;
var SB:    TStringBuilder;
    Items: array of record Titulo, Corpo: string; end;
    I:     Integer;
begin
  SetLength(Items, 3);
  Items[0].Titulo := 'Novidade 1'; Items[0].Corpo := 'Conteúdo da notícia 1.';
  Items[1].Titulo := 'Novidade 2'; Items[1].Corpo := 'Conteúdo da notícia <b>2</b>.';
  Items[2].Titulo := 'Novidade 3'; Items[2].Corpo := 'Conteúdo da notícia 3.';

  SB := TStringBuilder.Create;
  try
    SB.AppendLine('<!DOCTYPE html>');
    SB.AppendLine('<html><head><meta charset="UTF-8"><title>Relatório</title></head>');
    SB.AppendLine('<body>');
    SB.AppendLine('<h1>Relatório Gerado em ' +
      FormatDateTime('dd/mm/yyyy', Now) + '</h1>');
    SB.AppendLine('<table border="1">');
    SB.AppendLine('  <tr><th>Título</th><th>Corpo</th></tr>');

    for I := 0 to High(Items) do
    begin
      SB.AppendFormat('  <tr><td>%s</td><td>%s</td></tr>'#13#10,
        [Items[I].Titulo, Items[I].Corpo]);
    end;

    SB.AppendLine('</table>');
    SB.AppendLine('</body></html>');

    Writeln(SB.ToString);
    Writeln('HTML gerado: ', SB.Length, ' chars');
  finally
    SB.Free;
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoStringBuilderBasico;
//   DemoStringBuilderPerformance;
//   DemoStringBuilderEdit;
//   DemoBuildCSV;
//   DemoBuildHTML;
// ---------------------------------------------------------------------------

end.
