# Catálogo de Code Smells em Delphi
## Baseado em Martin Fowler + Robert C. Martin + laudos técnicos reais

---

## 1. Long Method (Método Longo)

**Definição:** Método com mais de 50 linhas de código.

**Como detectar:**
```bash
find /projeto -name "*.pas" -exec wc -l {} + | sort -rn | head -20
grep -n "procedure\|function" arquivo.pas | awk -F: 'prev{print $2-prev, prev_name} {prev=$2; prev_name=$0}'
```

**Exemplos reais detectados em auditorias:**
- `procedure TFPedidos.FormCreate` — 300 linhas
- `procedure TFPedidos_DST.GravarPedido` — 1030 linhas
- `procedure TfServidorMT2.ConsultarPedido` — 706 linhas

**Solução:** Extract Method — extrair trechos em métodos menores com nomes significativos.

**Níveis de gravidade:**
- 50–100 linhas: ⚠️ ATENÇÃO
- 100–300 linhas: ⚠️ ATENÇÃO grave
- 300–500 linhas: 🚨 CRÍTICO
- 500+ linhas: 🚨 God Method

---

## 2. God Class / God Method (Classe/Método Divino)

**Definição:** Classe ou método que faz tudo — múltiplas responsabilidades completamente distintas.

**Sintomas:**
- Form com lógica fiscal, de pedidos, de e-mail e de relatório ao mesmo tempo
- DataModule com SQL de módulos completamente diferentes
- `GravarPedido` que também calcula impostos, envia NF-e e dispara e-mail

**Exemplos reais:**
- `UPedidos_DST.pas` — 13.000 linhas
- `UCalculoFaturamento.pas` — múltiplos métodos de 1500+ linhas
- `procedure GravarPedido` — 1030 linhas com lógica fiscal, de estoque e de e-mail

**Solução:** Extract Class — separar responsabilidades em classes especializadas.

---

## 3. Long Parameter List / Políade

**Definição:** Método com 4 ou mais parâmetros.

**Como detectar:**
```bash
grep -n "procedure\|function" arquivo.pas | grep -E "(.+;){3,}"
```

**Exemplos reais:**
```pascal
// Políade — 7 parâmetros
procedure CriarForeignKey(pTabelaFK, pCamposFK, pTabelaRef,
  pCamposRef: String; pDeleteCascade: Boolean = False;
  pTextoAdd: String = ''; pSetNullCascade: Boolean = False);

// Políade — 10 parâmetros
function ClienteLocal(pCPF, pNome, pEndereco, pNum,
  pBairro, pCEP, pCidade, pUF, pIdIfood, pComplemento: string): integer;
```

**Solução:**
- Criar `Record` ou classe para agrupar parâmetros relacionados
- Usar programação fluente (Fluent Interface)
- Separar responsabilidades (provavelmente o método está fazendo coisas demais)

---

## 4. Duplicate Code (Código Duplicado)

**Definição:** O mesmo ou muito semelhante código aparece em dois ou mais lugares.

**Como detectar:**
```bash
# Buscar método com mesmo nome em units diferentes
grep -rn "procedure ConfirmaTrans\|function ConfirmaTrans" /projeto --include="*.pas"
# Buscar blocos SQL idênticos
grep -rn "SELECT.*FROM.*WHERE" /projeto --include="*.pas" | sort | uniq -d
```

**Exemplos reais:**
- `ConfirmaTrans` repetido em duas units diferentes
- `CalculaTotais` possivelmente duplicado em `UCalculoFaturamento` e `UCalculoFiscal`
- Bloco de chamada REST iFood repetido 26 vezes com ~10 linhas cada (260 linhas redundantes)

**Riscos:**
- Correção de bug precisa ser feita em múltiplos locais
- Divergência de comportamento ao longo do tempo
- Aumento desnecessário de tamanho do código

**Solução:** Extract Method — centralizar em um único local.

---

## 5. Dead Code (Código Morto)

**Definição:** Código comentado, nunca executado, ou que não afeta o comportamento.

**Como detectar:**
```bash
# Blocos comentados { ... }
grep -c "^{" arquivo.pas
grep -c "^//" arquivo.pas
# Métodos/procedures nunca chamados (verificar manualmente)
```

**Exemplos reais:**
```pascal
// Código esquecido comentado há anos
{ TbPed_Prods.CloseOpen(True);
  TbPed_Servs.CloseOpen(True); }

// SQL inteiro comentado com observação
{if Sender = TabelaCODNATOPER then
begin
  Dados.QryAux.SQL.Text := 'select M.DESCRICAO...'
  ...
end; }
```

**Solução:** Remover. O Git guarda o histórico.

---

## 6. Primitive Obsession (Obsessão Primitiva)

**Definição:** Uso excessivo de tipos primitivos (String, Integer, Double) onde objetos
ou Records seriam mais adequados.

**Sintomas:**
```pascal
// RUIM — dados de endereço espalhados como strings primitivas
procedure SalvarCliente(ANome, ACPF, AEndereco, ANumero,
  ABairro, ACEP, ACidade, AUF: string);

// BOM — encapsulado em Record
type
  TEndereco = record
    Logradouro: string;
    Numero: string;
    Bairro: string;
    CEP: string;
    Cidade: string;
    UF: string;
  end;
procedure SalvarCliente(const ANome, ACPF: string;
  const AEndereco: TEndereco);
```

**Outros exemplos:**
- Usar `Integer` para representar status quando um `TStatusPedido = (spAberto, spFechado)` seria mais claro
- Usar `Double` para valor monetário quando `Currency` é mais correto
- Usar `String` para CPF/CNPJ sem validação encapsulada

---

## 7. Feature Envy (Inveja de Recursos)

**Definição:** Um método que parece mais interessado nos dados de outra classe do que da própria.

```pascal
// RUIM — TFPedidos acessando direto os dados do DataModule de outro módulo
procedure TFPedidos.CalcularFrete;
begin
  LAliquota := DMFiscal.QryAliquotas.FieldByName('ALIQ').AsFloat;
  LUF := DMCliente.QryCliente.FieldByName('UF').AsString;
  LCEPDestino := DMCliente.QryCliente.FieldByName('CEP').AsString;
  // ...
end;

// BOM — o cálculo de frete pertence a um serviço de frete
LFrete := TFreteService.Calcular(ACliente, AItens);
```

---

## 8. Data Clumps (Grupos de Dados)

**Definição:** Grupos de variáveis que sempre aparecem juntas — candidatos a Record ou Classe.

```pascal
// RUIM — LNome, LCPF, LCNPJ sempre aparecem juntos
procedure Proc1(ALNome, ALCPF, ALCNPJ: string);
procedure Proc2(ALNome, ALCPF, ALCNPJ: string);

// BOM
type
  TDadosCliente = record
    Nome: string;
    CPF: string;
    CNPJ: string;
  end;
```

---

## 9. Cyclomatic Complexity (Complexidade Ciclomática)

**Definição:** Alto número de caminhos de execução em um método — excesso de
if/case/while/and/or aninhados.

**Como medir:** Número de pontos de decisão + 1. Ideal: até 5. Acima de 10: alto risco.

```pascal
// RUIM — complexidade ciclomática altíssima
procedure ProcessarPedido;
begin
  if ACliente.Ativo then
  begin
    if ACliente.LimiteCredito > 0 then
    begin
      if APedido.Total <= ACliente.LimiteCredito then
      begin
        if APedido.Itens.Count > 0 then
        begin
          if not AEstoque.EmFalta then
          begin
            // 5 níveis de aninhamento
          end;
        end;
      end;
    end;
  end;
end;
```

**Solução:** Guard clauses, Extract Method, Strategy Pattern.

---

## 10. Shotgun Surgery (Cirurgia de Espingarda)

**Definição:** Uma única mudança exige alterações em muitos lugares diferentes.

**Sintomas:**
- Alterar uma regra de negócio exige modificar 10+ units
- Renomear um campo do banco exige busca em centenas de arquivos
- SQL hardcoded espalhado que usa o mesmo campo

**Solução:** Centralizar regras — repositórios, constantes, configurações.

---

## 11. Inappropriate Intimacy (Intimidade Inapropriada)

**Definição:** Forms/units acessando diretamente campos internos de outros forms/units.

```pascal
// RUIM — acessando campo privado de outro Form
FFaturamentos.wwDBGrid4.Visible := False;
FPedidos.Edit1.Text := LValor;

// BOM — através de método/propriedade pública
FFaturamentos.OcultarGrid;
FPedidos.InformarValor(LValor);
```

---

## 12. Magic Numbers (Números Mágicos)

**Definição:** Literais numéricos sem significado explícito no código.

```pascal
// RUIM
if LStatus = 2 then ShowMessage('Aprovado');
if LDias > 30 then CobrarJuros;
LValor := LBase * 0.175;

// BOM
const
  C_STATUS_APROVADO = 2;
  C_PRAZO_MAXIMO_DIAS = 30;
  C_ALIQUOTA_ICMS_SP = 0.175;

if LStatus = C_STATUS_APROVADO then ShowMessage('Aprovado');
if LDias > C_PRAZO_MAXIMO_DIAS then CobrarJuros;
LValor := LBase * C_ALIQUOTA_ICMS_SP;
```

---

## 13. RecordCount — Code Smell de Performance

**Definição:** Uso de `RecordCount` quando apenas `IsEmpty` é necessário.

**Por que é um problema:** `RecordCount` percorre TODOS os registros do DataSet para contar.
Em sistemas Client/Server com tabelas grandes, isso pode causar travamentos visíveis.

```bash
# Contar ocorrências no projeto
grep -rn "RecordCount" /projeto --include="*.pas" | wc -l
```

**Exemplos reais:** 750+ ocorrências (WMC), 720+ ocorrências (ThR)

```pascal
// RUIM — RecordCount para verificar se tem dados
if QryPedidos.RecordCount > 0 then ProcessarPedidos;

// BOM — IsEmpty é O(1), não percorre registros
if not QryPedidos.IsEmpty then ProcessarPedidos;

// Se precisar de contagem real:
// SELECT COUNT(*) FROM TABELA WHERE CONDICAO
```

---

## 14. Locate — Code Smell de Performance

**Definição:** Uso excessivo de `Locate` em DataSets grandes.

**Por que é um problema:** `Locate` percorre registros sequencialmente sem usar índices.

**Exemplos reais:** 320+ ocorrências (ThR)

```pascal
// RUIM
QryProdutos.Locate('CODPRODUTO', LCodigo, []);

// BOM — FindKey usa índice previamente criado
QryProdutos.IndexFieldNames := 'CODPRODUTO';
QryProdutos.FindKey([LCodigo]);
// ou FindNearest para busca parcial
```

---

## 15. Uso de WITH — Code Smell Estrutural

**Definição:** O comando `with` é proibido pelo Delphi Style Guide.

**Por que é um problema:**
- Dificulta depuração (qual objeto está sendo referenciado?)
- Confunde o compilador em ambiguidades
- Dificulta refatoração e análise estática

```pascal
// RUIM — with proibido
with QryAux do
begin
  Close;
  SQL.Clear;
  SQL.Add('SELECT...');
  Open;
end;

// BOM — referência explícita
LQryAux.Close;
LQryAux.SQL.Clear;
LQryAux.SQL.Add('SELECT...');
LQryAux.Open;
```

---

## 16. SQL Espalhado — Code Smell Arquitetural

**Definição:** Instruções SQL embutidas diretamente em Forms e DataModules.

**Como detectar:**
```bash
grep -rn "SQL.Add\|SQL.Text\s*:=" /projeto --include="*.pas" | wc -l
grep -l "SQL.Add" /projeto --include="*.pas"
```

**Solução:** Centralizar em units de repositório/SQL:
```pascal
// Unit: Sistema.SQL.Pedidos.pas
const
  C_SQL_BUSCAR_PEDIDO_POR_CLIENTE =
    'SELECT P.NROPEDIDO, P.DTPEDIDO, P.TOTAL ' +
    'FROM PEDIDOS P ' +
    'WHERE P.CODCLIENTE = :CODCLIENTE ' +
    'AND P.STATUS = :STATUS ' +
    'ORDER BY P.DTPEDIDO DESC';
```
