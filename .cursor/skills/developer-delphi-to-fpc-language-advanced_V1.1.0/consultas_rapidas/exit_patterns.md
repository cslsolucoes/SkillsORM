# Exit(value), Guard Clauses e Early Return

## Exit com valor (Delphi 2006+)

```pascal
// Antes de Delphi 2006 — precisa atribuir Result antes do Exit
function Calcular(N: Integer): Integer;
begin
  if N < 0 then begin Result := -1; Exit; end;
  Result := N * 2;
end;

// Delphi 2006+ — Exit com valor (mais limpo)
function Calcular(N: Integer): Integer;
begin
  if N < 0 then Exit(-1);  // atribui E retorna
  Result := N * 2;
end;
```

## Guard clause — princípio

**Regra:** validar pré-condições primeiro, com exit antecipado, deixando o caminho "feliz" no final sem indentação extra.

```pascal
// RUIM — "arrow code" (pirâmide de if aninhados)
function ProcessarCliente(AId: Integer; const ANome: string): string;
begin
  if AId > 0 then
    if not ANome.IsEmpty then
      if ANome.Length < 100 then
        Result := Format('Cliente %d: %s', [AId, ANome])
      else
        Result := 'Nome muito longo'
    else
      Result := 'Nome vazio'
  else
    Result := 'ID inválido';
end;

// BOM — guard clauses lineares
function ProcessarCliente(AId: Integer; const ANome: string): string;
begin
  if AId <= 0            then Exit('ID inválido');
  if ANome.IsEmpty       then Exit('Nome vazio');
  if ANome.Length >= 100 then Exit('Nome muito longo');
  Result := Format('Cliente %d: %s', [AId, ANome]);
end;
```

## Padrões comuns de guard clause

### Guard: validação de parâmetros
```pascal
procedure Salvar(AEntidade: TObject; ARepo: IRepository);
begin
  if AEntidade = nil then raise EArgumentNilException.Create('AEntidade');
  if ARepo = nil     then raise EArgumentNilException.Create('ARepo');
  // ... código principal
end;
```

### Guard: estado inválido
```pascal
function TConexao.Executar(const ASQL: string): TDataSet;
begin
  if not FConectado  then Exit(nil);
  if ASQL.IsEmpty    then Exit(nil);
  // ... executar SQL
end;
```

### Guard: valor já calculado (cache)
```pascal
function TConfig.ObterValor(const AChave: string): string;
begin
  if FCache.TryGetValue(AChave, Result) then Exit;  // cache hit
  Result := FStorage.Ler(AChave);
  FCache.Add(AChave, Result);
end;
```

### Guard: condição de parada em loop
```pascal
function EncontrarItem(const ALista: TArray<TItem>;
  AId: Integer): TItem;
begin
  for var Item in ALista do
    if Item.Id = AId then Exit(Item);  // encontrado → sai do loop E da função
  Result := nil;  // não encontrado
end;
```

## Exit em procedures (sem valor)

```pascal
procedure LogarErro(const AMensagem: string);
begin
  if not FLogAtivo  then Exit;  // saída antecipada sem valor
  if AMensagem.IsEmpty then Exit;
  FLog.Add(Format('[%s] %s', [DateTimeToStr(Now), AMensagem]));
end;
```

## Comparação de legibilidade

```
Guard clause (early return):
  + Lógica de validação explícita no topo
  + Caminho feliz sem indentação extra
  + Fácil de adicionar nova validação
  - Múltiplos pontos de saída (alguns consideram negativo)

Nested if:
  - Difícil de ler com > 2 níveis
  - Fácil de esquecer um else
  + Único ponto de saída (alguns consideram positivo)

Regra de ouro: prefira guard clauses para validações,
use único retorno apenas quando o fluxo principal é simples.
```
