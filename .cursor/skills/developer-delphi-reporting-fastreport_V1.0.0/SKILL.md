---
name: developer-delphi-reporting-fastreport
description: >
  Relatórios FastReport no Delphi: TfrxReport, TfrxDBDataset, TfrxPreviewForm,
  design em tempo de execução, variáveis, parâmetros, grupos, totais, subrelatórios,
  exportação para PDF/Excel/HTML, impressão direta, personalização via código.
  Ativar quando o usuário mencionar: FastReport, TfrxReport, relatório Delphi,
  impressão Delphi, frxReport, preview relatório, TfrxDBDataset, TfrxPreviewForm,
  exportar PDF relatório, totais relatório, grupo relatório, subrelatório,
  FastReport variável, FastReport parâmetro.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-reporting-fastreport

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | Relatórios |

## Responsabilidade única

Criar, configurar e exibir relatórios FastReport: vincular datasets, configurar
variáveis e parâmetros, exibir preview, imprimir e exportar para PDF/Excel.

## When to use

- Criar relatório FastReport vinculado a TFDQuery
- Exibir preview em tela (`frxReport.ShowReport`)
- Imprimir diretamente (`frxReport.PrintReport`)
- Exportar relatório para PDF, Excel, HTML
- Personalizar relatório via código (variáveis, parâmetros, eventos)
- Configurar grupos, totais, subrelatórios

## When NOT to use

- Acesso ao banco de dados → `developer-delphi-firedac-queries`
- Relatórios com outras engines (ReportBuilder, Fortes) → skills próprias

---

## §1 — Configuração básica (TfrxReport + TfrxDBDataset)

```pascal
uses
  frxClass,         // TfrxReport, TfrxComponent
  frxDBSet,         // TfrxDBDataset
  frxPreview,       // TfrxPreviewForm
  frxExportPDF,     // TfrxPDFExport
  frxExportXLS;     // TfrxXLSExport

// No DataModule ou Form
type
  TdmRelatorios = class(TDataModule)
    rptClientes: TfrxReport;
    dsrClientes: TfrxDBDataset;   // DataSet = qryClientes
    // qryClientes: TFDQuery (configurada separadamente)
  end;

procedure TdmRelatorios.ConfigurarRelatorio;
begin
  // Vincular dataset ao componente FastReport
  dsrClientes.DataSet := qryClientes;
  dsrClientes.Name    := 'DSClientes';  // nome referenciado no .frx

  // Apontar o relatório para o arquivo .frx
  rptClientes.LoadFromFile(
    ExtractFilePath(Application.ExeName) + 'reports\clientes.frx');
end;
```

---

## §2 — Exibir preview e imprimir

```pascal
// Preview em tela (abre janela de visualização)
procedure TfrmPrincipal.VisualizarRelatorio;
begin
  dmRelatorios.qryClientes.Close;
  dmRelatorios.qryClientes.Open;

  dmRelatorios.rptClientes.ShowReport;  // exibe preview
end;

// Imprimir diretamente (sem preview)
procedure TfrmPrincipal.ImprimirDireto;
begin
  dmRelatorios.qryClientes.Open;
  dmRelatorios.rptClientes.PrintReport;
end;

// Preview silencioso (sem dialog de impressora)
procedure TfrmPrincipal.VisualizarSilencioso;
begin
  dmRelatorios.rptClientes.SilentMode := True;
  dmRelatorios.rptClientes.PrepareReport;
  dmRelatorios.rptClientes.ShowPreparedReport;
end;
```

---

## §3 — Variáveis e parâmetros em tempo de execução

```pascal
// Passar valores para o relatório via variáveis
procedure TfrmPrincipal.AbrirRelatorioFiltrado(
  const ADataIni, ADataFim: TDateTime;
  const AUsuario: string);
begin
  // Definir variáveis — acessíveis no relatório como [NomeVar]
  dmRelatorios.rptVendas.Variables['DATA_INI']  := DateToStr(ADataIni);
  dmRelatorios.rptVendas.Variables['DATA_FIM']  := DateToStr(ADataFim);
  dmRelatorios.rptVendas.Variables['USUARIO']   := AUsuario;
  dmRelatorios.rptVendas.Variables['EMISSAO']   := DateTimeToStr(Now);

  // Query com parâmetros aplicados antes do ShowReport
  dmRelatorios.qryVendas.Close;
  dmRelatorios.qryVendas.ParamByName('DATA_INI').AsDateTime := ADataIni;
  dmRelatorios.qryVendas.ParamByName('DATA_FIM').AsDateTime := ADataFim;
  dmRelatorios.qryVendas.Open;

  dmRelatorios.rptVendas.ShowReport;
end;
```

---

## §4 — Exportação para PDF e Excel

```pascal
uses frxExportPDF, frxExportXLS;

// Exportar para PDF
procedure TfrmPrincipal.ExportarPDF(const ACaminho: string);
var LExport: TfrxPDFExport;
begin
  LExport := TfrxPDFExport.Create(nil);
  try
    LExport.FileName   := ACaminho;
    LExport.ShowDialog := False;   // sem dialog "Salvar como"
    LExport.Author     := 'Sistema CSL';
    LExport.OpenAfterExport := False;

    dmRelatorios.qryClientes.Open;
    dmRelatorios.rptClientes.PrepareReport;
    dmRelatorios.rptClientes.Export(LExport);
  finally
    LExport.Free;
  end;
end;

// Exportar para Excel
procedure TfrmPrincipal.ExportarExcel(const ACaminho: string);
var LExport: TfrxXLSExport;
begin
  LExport := TfrxXLSExport.Create(nil);
  try
    LExport.FileName   := ACaminho;
    LExport.ShowDialog := False;

    dmRelatorios.rptClientes.PrepareReport;
    dmRelatorios.rptClientes.Export(LExport);
  finally
    LExport.Free;
  end;
end;

// Exportar para stream (PDF em memória — útil para e-mail)
function TfrmPrincipal.GerarPDFStream: TMemoryStream;
var LExport: TfrxPDFExport;
begin
  Result := TMemoryStream.Create;
  LExport := TfrxPDFExport.Create(nil);
  try
    LExport.Stream     := Result;
    LExport.ShowDialog := False;
    dmRelatorios.rptClientes.PrepareReport;
    dmRelatorios.rptClientes.Export(LExport);
  finally
    LExport.Free;
  end;
end;
```

---

## §5 — Eventos de relatório (personalização via código)

```pascal
// OnBeforePrint — executado antes de imprimir cada objeto
procedure TdmRelatorios.rptClientesOnBeforePrint(
  Sender: TfrxComponent);
begin
  // Colorir linha alternada no detail band
  if Sender.Name = 'MemoNome' then
  begin
    var LBand := Sender.Parent as TfrxDetailData;
    if Odd(dmRelatorios.dsrClientes.DataSet.RecNo) then
      LBand.Color := $00EEF0F0
    else
      LBand.Color := clWhite;
  end;
end;

// OnGetValue — fornecer valor de variável em tempo de execução
procedure TdmRelatorios.rptClientesOnGetValue(
  const VarName: string; var Value: Variant);
begin
  if VarName = 'TOTAL_GERAL' then
    Value := FTotalGeral;   // campo calculado externamente
end;
```

---

## §6 — Relatório por código (sem arquivo .frx)

```pascal
// Criar relatório programaticamente (sem designer)
procedure TfrmPrincipal.CriarRelatorioSimples;
var
  LRpt: TfrxReport;
  LPage: TfrxReportPage;
  LBand: TfrxReportTitle;
  LMemo: TfrxMemoView;
begin
  LRpt  := TfrxReport.Create(nil);
  try
    LPage := TfrxReportPage.Create(LRpt);
    LPage.CreateUniqueName;
    LPage.SetDefaults;

    LBand := TfrxReportTitle.Create(LPage);
    LBand.SetBounds(0, 0, LPage.Width, 30);

    LMemo := TfrxMemoView.Create(LBand);
    LMemo.SetBounds(0, 0, LPage.Width, 20);
    LMemo.Text := 'RELATÓRIO DE CLIENTES';
    LMemo.Font.Size := 14;
    LMemo.Font.Style := [fsBold];
    LMemo.HAlign := haCenter;

    LRpt.ShowReport;
  finally
    LRpt.Free;
  end;
end;
```

---

## §7 — Checklist de qualidade — FastReport

- [ ] Arquivo `.frx` no diretório de relatórios, referenciado por caminho relativo ao executável
- [ ] Query aberta (`Open`) antes de `ShowReport` ou `PrepareReport`
- [ ] `TfrxDBDataset.Name` igual ao nome usado no design do relatório
- [ ] Variáveis definidas antes de `ShowReport`
- [ ] `SilentMode := True` para geração sem interação do usuário (batch, e-mail)
- [ ] `Export` com `ShowDialog := False` para exportação automática
- [ ] Stream liberado pelo caller quando `GerarPDFStream` retorna `TMemoryStream`
- [ ] `rptClientes.Free` (se criado dinamicamente) no `finally`

## Referências cruzadas

- `developer-delphi-firedac-queries` — TFDQuery como DataSet do relatório
- `developer-delphi-indy-email` — enviar PDF gerado por e-mail
