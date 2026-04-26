unit tdictionary;
{
  TDictionary<K,V> — Add, TryGetValue, iteração, grupos, lookup
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

procedure DemoDictionaryBasico;
procedure DemoDictionaryObjetos;
procedure DemoAgrupamento;
procedure DemoFrequencia;
procedure DemoInverso;

implementation

// ---------------------------------------------------------------------------
// DemoDictionaryBasico
// ---------------------------------------------------------------------------

procedure DemoDictionaryBasico;
var D: TDictionary<string, Integer>;
    Pair: TPair<string, Integer>;
    Idade: Integer;
begin
  D := TDictionary<string, Integer>.Create;
  try
    // Adicionar
    D.Add('alice', 25);
    D.Add('bob', 30);
    D.Add('carol', 28);

    // AddOrSetValue — não lança se já existe
    D.AddOrSetValue('bob', 31);   // atualiza bob
    D.AddOrSetValue('dave', 22);  // insere dave

    // Leitura direta (lança EKeyNotFoundException se não existir)
    Writeln('alice:', D['alice']);

    // Leitura segura — preferir TryGetValue
    if D.TryGetValue('carol', Idade) then
      Writeln('carol:', Idade)
    else
      Writeln('carol: não encontrado');

    if not D.TryGetValue('eve', Idade) then
      Writeln('eve: não encontrada');

    // Verificar existência
    Writeln('ContainsKey bob: ', D.ContainsKey('bob'));
    Writeln('ContainsValue 22: ', D.ContainsValue(22));

    // Remover
    D.Remove('dave');
    Writeln('Após Remove(dave), Count=', D.Count);

    // Iteração sobre pares
    Writeln('--- Todos os pares ---');
    for Pair in D do
      Writeln(Pair.Key, ' → ', Pair.Value);

    // Iteração sobre chaves / valores
    Write('Chaves: ');
    for var K in D.Keys do Write(K, ' ');
    Writeln;
    Write('Valores: ');
    for var V in D.Values do Write(V, ' ');
    Writeln;

    // ExtractPair — remove e retorna o par
    var P := D.ExtractPair('alice');
    Writeln('Extraído: ', P.Key, '=', P.Value);
    Writeln('Count após Extract: ', D.Count);
  finally
    D.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoDictionaryObjetos
// ---------------------------------------------------------------------------

type
  TCliente = class
    Id:   Integer;
    Nome: string;
    Saldo: Currency;
    constructor Create(AId: Integer; const ANome: string; ASaldo: Currency);
    function ToString: string; override;
  end;

constructor TCliente.Create(AId: Integer; const ANome: string; ASaldo: Currency);
begin inherited Create; Id := AId; Nome := ANome; Saldo := ASaldo; end;

function TCliente.ToString: string;
begin Result := Format('[%d] %s R$%.2f', [Id, Nome, Saldo]); end;

procedure DemoDictionaryObjetos;
var D: TObjectDictionary<Integer, TCliente>;
    C: TCliente;
begin
  // TObjectDictionary gerencia lifetime dos valores
  D := TObjectDictionary<Integer, TCliente>.Create([doOwnsValues]);
  try
    D.Add(1, TCliente.Create(1, 'Alice', 1500));
    D.Add(2, TCliente.Create(2, 'Bob',   2300));
    D.Add(3, TCliente.Create(3, 'Carol', 800));

    // Lookup por ID
    if D.TryGetValue(2, C) then
      Writeln('Encontrado: ', C.ToString);

    // Atualizar saldo
    if D.TryGetValue(1, C) then
      C.Saldo := C.Saldo + 500;

    // Remover — D libera o objeto automaticamente (doOwnsValues)
    D.Remove(3);

    Writeln('--- Clientes ---');
    for var Pair in D do
      Writeln(Pair.Value.ToString);
  finally
    D.Free;  // libera todos os TCliente
  end;
end;

// ---------------------------------------------------------------------------
// DemoAgrupamento — equivalente a GROUP BY
// ---------------------------------------------------------------------------

procedure DemoAgrupamento;
type TGrupo = TList<string>;
var Grupos: TObjectDictionary<string, TGrupo>;
    Produtos: TArray<TPair<string, string>>;  // (nome, categoria)
    P: TPair<string, string>;
    G: TGrupo;
    Cat: string;
begin
  Produtos := [
    TPair<string,string>.Create('Caneta',    'Escritório'),
    TPair<string,string>.Create('Caderno',   'Escritório'),
    TPair<string,string>.Create('Mouse',     'Tech'),
    TPair<string,string>.Create('Teclado',   'Tech'),
    TPair<string,string>.Create('Monitor',   'Tech'),
    TPair<string,string>.Create('Borracha',  'Escritório')
  ];

  Grupos := TObjectDictionary<string, TGrupo>.Create([doOwnsValues]);
  try
    for P in Produtos do
    begin
      if not Grupos.TryGetValue(P.Value, G) then
      begin
        G := TGrupo.Create;
        Grupos.Add(P.Value, G);
      end;
      G.Add(P.Key);
    end;

    Writeln('--- Grupos por categoria ---');
    for Cat in Grupos.Keys do
    begin
      Write(Cat, ': ');
      G := Grupos[Cat];
      for var S in G do Write(S, ' ');
      Writeln;
    end;
  finally
    Grupos.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoFrequencia — contagem de palavras
// ---------------------------------------------------------------------------

procedure DemoFrequencia;
var Freq: TDictionary<string, Integer>;
    Palavras: TArray<string>;
    W: string;
    Cont: Integer;
begin
  Palavras := ['ola', 'mundo', 'ola', 'delphi', 'mundo', 'ola', 'rtl'];
  Freq := TDictionary<string, Integer>.Create;
  try
    for W in Palavras do
    begin
      if Freq.TryGetValue(W, Cont) then Freq[W] := Cont + 1
      else Freq.Add(W, 1);
    end;
    Writeln('--- Frequência ---');
    for var Pair in Freq do
      Writeln(Pair.Key, ': ', Pair.Value);
  finally
    Freq.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoInverso — inverter dicionário (valor → chave)
// ---------------------------------------------------------------------------

procedure DemoInverso;
var Original: TDictionary<string, Integer>;
    Invertido: TDictionary<Integer, string>;
    Pair: TPair<string, Integer>;
begin
  Original := TDictionary<string, Integer>.Create;
  Invertido := TDictionary<Integer, string>.Create;
  try
    Original.Add('Alice', 101);
    Original.Add('Bob',   102);
    Original.Add('Carol', 103);

    for Pair in Original do
      Invertido.Add(Pair.Value, Pair.Key);

    Writeln('--- Lookup por ID ---');
    Writeln('102 → ', Invertido[102]);
    Writeln('103 → ', Invertido[103]);
  finally
    Original.Free;
    Invertido.Free;
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoDictionaryBasico;
//   DemoDictionaryObjetos;
//   DemoAgrupamento;
//   DemoFrequencia;
//   DemoInverso;
// ---------------------------------------------------------------------------

end.
