unit regex_delphi;
{
  TRegEx — IsMatch, Match, Matches, Replace, Split; grupos; flags
  Compilavel: dcc32 / dcc64
  Uses: System.RegularExpressions
}

interface

uses
  System.SysUtils, System.RegularExpressions, System.Generics.Collections;

procedure DemoRegExBasico;
procedure DemoRegExGrupos;
procedure DemoRegExReplace;
procedure DemoRegExSplit;
procedure DemoRegExValidacoes;

implementation

// ---------------------------------------------------------------------------
// DemoRegExBasico — IsMatch, Match, Matches
// ---------------------------------------------------------------------------

procedure DemoRegExBasico;
var M:  TMatch;
    MC: TMatchCollection;
begin
  // IsMatch — verificação rápida (True/False)
  Writeln('CEP: ', TRegEx.IsMatch('01310-100', '^\d{5}-\d{3}$'));  // True
  Writeln('CEP: ', TRegEx.IsMatch('01310100',  '^\d{5}-\d{3}$'));  // False

  // Match — primeiro match
  M := TRegEx.Match('preço: R$ 1.234,56 e R$ 789,00', 'R\$\s*[\d.,]+');
  if M.Success then
    Writeln('Primeiro match: ', M.Value);  // 'R$ 1.234,56'

  // Matches — todos os matches
  MC := TRegEx.Matches('abc 123 def 456 ghi 789', '\d+');
  Writeln('Total matches: ', MC.Count);
  for M in MC do
    Writeln('  Match: ', M.Value, ' em pos=', M.Index);
  // 123, 456, 789

  // Match.Index é base 1 (posição na string original)
  M := TRegEx.Match('Hello World', 'World');
  Writeln('Index de "World": ', M.Index);  // 7 (base 1)
  Writeln('Length: ', M.Length);           // 5

  // NextMatch — iterar manualmente
  M := TRegEx.Match('um dois três quatro', '\b\w{4,}\b');
  while M.Success do
  begin
    Writeln('Palavra >=4 chars: ', M.Value);
    M := M.NextMatch;
  end;
  // três, dois (>=4 chars), quatro
end;

// ---------------------------------------------------------------------------
// DemoRegExGrupos — captura de grupos nomeados e indexados
// ---------------------------------------------------------------------------

procedure DemoRegExGrupos;
var M: TMatch;
begin
  // Grupos por índice — 0 = match completo, 1+ = grupos
  M := TRegEx.Match('2026-04-11', '^(\d{4})-(\d{2})-(\d{2})$');
  if M.Success then
  begin
    Writeln('Ano:  ', M.Groups[1].Value);  // 2026
    Writeln('Mês:  ', M.Groups[2].Value);  // 04
    Writeln('Dia:  ', M.Groups[3].Value);  // 11
    Writeln('Full: ', M.Groups[0].Value);  // 2026-04-11
  end;

  // Grupos nomeados — (?P<nome>...) ou (?<nome>...)
  M := TRegEx.Match('alice.silva@empresa.com.br',
    '^(?P<user>[^@]+)@(?P<domain>[^.]+)\.(?P<tld>.+)$');
  if M.Success then
  begin
    Writeln('User:   ', M.Groups['user'].Value);   // alice.silva
    Writeln('Domain: ', M.Groups['domain'].Value); // empresa
    Writeln('TLD:    ', M.Groups['tld'].Value);    // com.br
  end;

  // Grupo que pode não capturar (opcional)
  M := TRegEx.Match('+55 (11) 98765-4321',
    '^(\+\d{1,3}\s)?(\(?\d{2}\)?\s?)(\d{4,5}[-\s]?\d{4})$');
  if M.Success then
  begin
    Writeln('DDI: ',    M.Groups[1].Value);  // '+55 '
    Writeln('DDD: ',    M.Groups[2].Value);  // '(11) '
    Writeln('Número: ', M.Groups[3].Value);  // '98765-4321'
  end;
end;

// ---------------------------------------------------------------------------
// DemoRegExReplace — substituição com callback e backreferences
// ---------------------------------------------------------------------------

procedure DemoRegExReplace;
var S: string;
begin
  // Replace básico
  S := TRegEx.Replace('Telefone: (11) 9876-5432', '[^0-9]', '');
  Writeln('Só dígitos: ', S);  // '1198765432'

  // Replace com TMatchEvaluator (callback por match)
  var Texto := 'João ganha 1500 e Maria ganha 3200';
  var ComReajuste := TRegEx.Replace(Texto, '\d+',
    function(const M: TMatch): string
    begin
      Result := IntToStr(Round(StrToInt(M.Value) * 1.1));
    end);
  Writeln('Com 10% reajuste: ', ComReajuste);
  // 'João ganha 1650 e Maria ganha 3520'

  // Replace com backreference — $1 = grupo 1
  S := TRegEx.Replace('2026-04-11', '^(\d{4})-(\d{2})-(\d{2})$', '$3/$2/$1');
  Writeln('ISO → BR: ', S);  // '11/04/2026'

  // Replace insensível a maiúsculas
  S := TRegEx.Replace('Delphi é delphi é DELPHI', 'delphi',
    'Pascal', [roIgnoreCase]);
  Writeln('Replace ci: ', S);
  // 'Pascal é Pascal é Pascal'

  // Replace com limite de ocorrências (sem parâmetro nativo — usar loop manual)
  var RE := TRegEx.Create('\d+');
  var Count := 0;
  S := RE.Replace('1 2 3 4 5',
    function(const M: TMatch): string
    begin
      Inc(Count);
      if Count <= 3 then Result := '*'
      else Result := M.Value;
    end);
  Writeln('Replace 3 primeiros: ', S);  // '* * * 4 5'
end;

// ---------------------------------------------------------------------------
// DemoRegExSplit — divisão por padrão
// ---------------------------------------------------------------------------

procedure DemoRegExSplit;
var Partes: TArray<string>;
    P: string;
begin
  // Split por um ou mais espaços
  Partes := TRegEx.Split('um   dois  três    quatro', '\s+');
  Writeln('Split \s+: ', Length(Partes), ' partes');
  for P in Partes do Write('[', P, '] ');
  Writeln;

  // Split por separadores múltiplos
  Partes := TRegEx.Split('a,b;c|d', '[,;|]');
  for P in Partes do Write('[', P, '] ');
  Writeln;
  // [a] [b] [c] [d]

  // Split por fronteira de palavra
  Partes := TRegEx.Split('CamelCaseIdentifier', '(?=[A-Z])');
  for P in Partes do Write('[', P, '] ');
  Writeln;
  // [Camel] [Case] [Identifier]
end;

// ---------------------------------------------------------------------------
// DemoRegExValidacoes — padrões de validação comuns
// ---------------------------------------------------------------------------

procedure ValidarEMostrar(const ADesc, AValor, APattern: string;
  AFlags: TRegExOptions = []);
begin
  var OK := TRegEx.IsMatch(AValor, APattern, AFlags);
  Writeln(Format('%-12s  %-30s  %s', [ADesc, AValor, BoolToStr(OK, True)]));
end;

procedure DemoRegExValidacoes;
begin
  Writeln('Descrição     Valor                           Válido');
  Writeln(StringOfChar('-', 60));

  // E-mail simplificado
  ValidarEMostrar('Email', 'alice@exemplo.com',
    '^[\w.+-]+@[\w-]+\.[a-z]{2,}$', [roIgnoreCase]);
  ValidarEMostrar('Email inv.', 'alice@',
    '^[\w.+-]+@[\w-]+\.[a-z]{2,}$', [roIgnoreCase]);

  // CPF formato
  ValidarEMostrar('CPF', '123.456.789-09', '^\d{3}\.\d{3}\.\d{3}-\d{2}$');
  ValidarEMostrar('CPF inv.', '12345678909', '^\d{3}\.\d{3}\.\d{3}-\d{2}$');

  // CNPJ formato
  ValidarEMostrar('CNPJ', '12.345.678/0001-95',
    '^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$');

  // CEP
  ValidarEMostrar('CEP', '01310-100', '^\d{5}-\d{3}$');
  ValidarEMostrar('CEP inv.', '01310100', '^\d{5}-\d{3}$');

  // URL básica
  ValidarEMostrar('URL', 'https://www.exemplo.com.br',
    '^https?://[\w.-]+(\.[a-z]{2,})+(/.*)?$', [roIgnoreCase]);

  // IPv4
  ValidarEMostrar('IPv4', '192.168.1.254',
    '^(\d{1,3}\.){3}\d{1,3}$');

  // Senha: mín 8 chars, 1 maiúscula, 1 minúscula, 1 dígito
  ValidarEMostrar('Senha forte', 'Abc12345',
    '^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$');
  ValidarEMostrar('Senha fraca', 'abc12345',
    '^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$');
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoRegExBasico;
//   DemoRegExGrupos;
//   DemoRegExReplace;
//   DemoRegExSplit;
//   DemoRegExValidacoes;
// ---------------------------------------------------------------------------

end.
