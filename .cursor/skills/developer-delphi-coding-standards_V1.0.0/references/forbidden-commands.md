# Comandos Proibidos e Restritos — Delphi Style Guide

## Tabela Resumo

| Comando | Status | Motivo |
|---|---|---|
| `with` | 🚫 PROIBIDO | Dificulta depuração, confunde compilador |
| `Break` | 🚫 PROIBIDO | Saída deve estar na condição do loop |
| `Continue` | 🚫 PROIBIDO | Desvio dificulta compreensão |
| `goto` | 🚫 PROIBIDO | — |
| `Exit` | ⚠️ RESTRITO | Apenas em guard clauses no início |
| `Abort` | 🚫 PROIBIDO | Esconde a pilha de chamadas |
| `Real` | 🚫 PROIBIDO | Obsoleto, substituído por `Double` |
| `Extended` | ⚠️ DESENCORAJADO | Tamanho não otimizado para processadores modernos |

---

## WITH — Proibido

**Motivo:** Dificulta depuração (qual objeto está sendo referenciado?),
confunde o compilador em ambiguidades, impossibilita análise estática.

```pascal
// ❌ ERRADO
with QryAux do
begin
  Close;
  SQL.Clear;
  SQL.Add('SELECT * FROM CLIENTES');
  Open;
end;

// ✅ CORRETO
LQryAux.Close;
LQryAux.SQL.Clear;
LQryAux.SQL.Add('SELECT * FROM CLIENTES');
LQryAux.Open;
```

---

## BREAK e CONTINUE — Proibidos

**Motivo:** Geram desvio de fluxo que dificulta a compreensão. A condição
de saída do loop deve estar na cláusula do loop.

```pascal
// ❌ ERRADO — Break no loop
for LI := 0 to LLista.Count - 1 do
begin
  if LLista[LI].Ativo then
    Break;
  ProcessarItem(LLista[LI]);
end;

// ✅ CORRETO — condição na declaração do loop
LI := 0;
while (LI < LLista.Count) and not LLista[LI].Ativo do
begin
  ProcessarItem(LLista[LI]);
  Inc(LI);
end;
```

---

## EXIT — Restrito a Guard Clauses

O `Exit` é permitido **exclusivamente** no início do método como cláusula de guarda,
para rejeitar condições inválidas antes da lógica principal.

```pascal
// ✅ CORRETO — guard clauses no início
procedure TService.ProcessarPedido(const APedido: TPedido);
begin
  if not Assigned(APedido) then Exit;
  if APedido.Valor <= 0 then Exit;
  if not FClienteValido then Exit;

  // lógica principal aqui — sem if aninhados
  FRepository.Salvar(APedido);
  FLogger.Log('Pedido processado: ' + APedido.Numero);
end;

// ❌ ERRADO — Exit no meio da lógica
procedure TService.ProcessarPedido(const APedido: TPedido);
begin
  FRepository.Salvar(APedido);
  if not FEnviarEmail then Exit; // Exit no meio — proibido
  FEmail.Enviar(APedido);
end;
```

---

## Loops — Regras

### FOR: usar quando o número de iterações é definido
### WHILE: usar quando o número de iterações é indefinido (mínimo 0 iterações)
### REPEAT: usar quando o loop deve executar pelo menos 1 vez

```pascal
// ✅ FOR com iterações definidas
for LI := 0 to LLista.Count - 1 do
  ProcessarItem(LLista[LI]);

// ✅ WHILE com condição composta (menor complexidade primeiro)
while LAtivo and (GetValorAtual < C_LIMITE_MAXIMO) do
begin
  ProcessarIteracao;
end;

// ✅ REPEAT com condição no until
repeat
  LTentativa := LTentativa + 1;
  LResultado := TentarConectar;
until LResultado or (LTentativa >= C_MAX_TENTATIVAS);
```

---

## IF — Ordem das Condições

Condições compostas devem estar ordenadas da **menor para a maior complexidade**
(esquerda para direita). O compilador usa short-circuit — finaliza quando uma
condição determina o resultado.

```pascal
// ✅ CORRETO — booleano simples primeiro, cálculo complexo só se necessário
if FAtivo and (GetCalculoComplexo < C_LIMITE) then
  Processar;

// ❌ ERRADO — cálculo pesado avaliado desnecessariamente
if (GetCalculoComplexo < C_LIMITE) and FAtivo then
  Processar;
```

---

## CASE — Regras

- Valores em ordem crescente
- Cada caso indentado em relação ao `case`
- Blocos com máximo 5 linhas (incluindo begin..end)
- `else` alinhado ao `case`, sem indentação extra

```pascal
// ✅ CORRETO
case LStatus of
  0: PedidoAberto;
  1: PedidoConfirmado;
  2: PedidoFaturado;
  3:
  begin
    CancelarPedido;
    NotificarCliente;
  end;
else
  raise EStatusInvalido.Create('Status desconhecido: ' + IntToStr(LStatus));
end;
```

---

## Exceções

### try..finally — Um recurso por bloco
```pascal
// ✅ CORRETO — um recurso por bloco
LObj1 := TClasse1.Create;
try
  LObj2 := TClasse2.Create;
  try
    LObj1.UsarCom(LObj2);
  finally
    LObj2.Free;
  end;
finally
  LObj1.Free;
end;

// ❌ ERRADO — dois recursos no mesmo bloco
LObj1 := TClasse1.Create;
LObj2 := TClasse2.Create;
try
  LObj1.UsarCom(LObj2);
finally
  LObj1.Free;
  LObj2.Free; // se LObj1.Free lançar, LObj2 vaza
end;
```

### try..except — Nunca silencioso
```pascal
// ❌ PROIBIDO — bloco vazio
try
  qry.ExecSQL;
except
  // vazio — esconde o erro
end;

// ✅ CORRETO — captura específica, loga e relança mensagem amigável
try
  qry.ExecSQL;
except
  on E: EDatabaseError do
  begin
    Logger.GravarErro('Falha ao salvar pedido: ' + E.Message);
    raise Exception.Create('Não foi possível salvar o pedido. Tente novamente.');
  end;
end;
```
