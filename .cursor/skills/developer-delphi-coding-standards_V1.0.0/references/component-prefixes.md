# Prefixos de Componentes — VCL e FMX

## Regra Geral

Todo componente **referenciado via código-fonte** deve ser renomeado com:
`[prefixo][NomeDescritivoEmCamelCase]`

Componentes não referenciados via código: tolerável manter nome default.

```pascal
// ❌ ERRADO — nomes default
Button1.Enabled := False;
Edit1.Text := '';
Label1.Caption := 'Carregando...';

// ✅ CORRETO — renomeados
btnSalvar.Enabled := False;
edtNomeCliente.Text := '';
lblStatus.Caption := 'Carregando...';
```

---

## Tabela de Prefixos

### Entrada de Dados
| Componente | Prefixo | Exemplos |
|---|---|---|
| TEdit / TFMXEdit | `edt` | `edtNome`, `edtCPF`, `edtValorVenda` |
| TMemo / TFMXMemo | `mmo` | `mmoObservacao`, `mmoLog` |
| TComboBox | `cbx` | `cbxEstado`, `cbxTipoPagamento` |
| TListBox | `lst` | `lstItens`, `lstClientes` |
| TCheckBox | `chk` | `chkAtivo`, `chkConcordoTermos` |
| TRadioButton | `rdb` | `rdbMasculino`, `rdbFeminino` |
| TDateTimePicker | `dtp` | `dtpDataNascimento`, `dtpVencimento` |
| TSpinEdit | `spe` | `speQuantidade`, `speNumeroParcelas` |
| TTrackBar | `trk` | `trkVolume`, `trkBrilho` |
| TNumberBox (FMX) | `nbx` | `nbxValor`, `nbxQuantidade` |

### Exibição
| Componente | Prefixo | Exemplos |
|---|---|---|
| TLabel | `lbl` | `lblTitulo`, `lblStatus`, `lblTotal` |
| TImage | `img` | `imgLogo`, `imgFoto`, `imgIcone` |
| TProgressBar | `prg` | `prgCarregamento`, `prgUpload` |

### Botões
| Componente | Prefixo | Exemplos |
|---|---|---|
| TButton | `btn` | `btnSalvar`, `btnCancelar`, `btnNovo` |
| TBitBtn | `bbt` | `bbtConfirmar`, `bbtExcluir` |
| TSpeedButton | `spb` | `spbImprimir`, `spbExportar` |
| TToolButton | `tbn` | `tbnSalvar`, `tbnAbrir` |

### Layout e Containers
| Componente | Prefixo | Exemplos |
|---|---|---|
| TPanel | `pnl` | `pnlCabecalho`, `pnlRodape`, `pnlFiltros` |
| TGroupBox | `grp` | `grpDadosPessoais`, `grpEndereco` |
| TPageControl | `pgc` | `pgcPrincipal`, `pgcCadastro` |
| TTabSheet | `tbs` | `tbsDadosGerais`, `tbsEndereco` |
| TScrollBox | `scb` | `scbConteudo`, `scbItens` |
| TSplitter | `spl` | `splVertical`, `splHorizontal` |
| TFrame | `frm` | `frmFiltros`, `frmRodape` |
| TLayout (FMX) | `lyt` | `lytCabecalho`, `lytBotoes` |
| TRectangle (FMX) | `rct` | `rctFundo`, `rctBordaAzul` |

### Grids e Listas
| Componente | Prefixo | Exemplos |
|---|---|---|
| TDBGrid | `grd` | `grdClientes`, `grdPedidos`, `grdItens` |
| TStringGrid | `sgr` | `sgrDados`, `sgrResumo` |
| TListView | `lsv` | `lsvArquivos`, `lsvResultados` |
| TTreeView | `trv` | `trvMenu`, `trvCategorias` |

### Dados
| Componente | Prefixo | Exemplos |
|---|---|---|
| TDataSource | `dts` | `dtsClientes`, `dtsPedidos` |
| TFDQuery / TQuery | `qry` | `qryClientes`, `qryPedidos`, `qryAux` |
| TFDTable / TTable | `tbl` | `tblProdutos`, `tblEstoque` |
| TFDConnection | `cnn` | `cnnPrincipal`, `cnnRelatorio` |
| TFDTransaction | `trn` | `trnPrincipal`, `trnLote` |
| TClientDataSet | `cds` | `cdsClientes`, `cdsPedidos` |
| TFDMemTable | `mdt` | `mdtResultados`, `mdtTemp` |

### Menu e Toolbar
| Componente | Prefixo | Exemplos |
|---|---|---|
| TMainMenu | `mnu` | `mnuPrincipal` |
| TPopupMenu | `pmu` | `pmuGrid`, `pmuIcone` |
| TMenuItem | `mni` | `mniArquivo`, `mniSalvar` |
| TToolBar | `tlb` | `tlbPrincipal`, `tlbFormatacao` |

### Diálogos
| Componente | Prefixo | Exemplos |
|---|---|---|
| TOpenDialog | `odlg` | `odlgArquivo`, `odlgImagem` |
| TSaveDialog | `sdlg` | `sdlgRelatorio`, `sdlgExportar` |
| TColorDialog | `cdlg` | `cdlgCor` |
| TFontDialog | `fdlg` | `fdlgTexto` |

### Temporização e Comunicação
| Componente | Prefixo | Exemplos |
|---|---|---|
| TTimer | `tmr` | `tmrAtualizacao`, `tmrSessao` |
| TRESTClient | `rtc` | `rtcAPI`, `rtcIfood` |
| TRESTRequest | `rtr` | `rtrBuscarPedidos`, `rtrAutenticar` |
| TRESTResponse | `rsp` | `rspPedidos`, `rspToken` |

### FMX Específico
| Componente | Prefixo | Exemplos |
|---|---|---|
| TForm (FMX) | `frm` | `frmPrincipal`, `frmCadastro` |
| TTabControl (FMX) | `tbc` | `tbcNavegacao` |
| TTabItem (FMX) | `tbi` | `tbiHome`, `tbiConfig` |
| TSwitch (FMX) | `swt` | `swtAtivo`, `swtNotificacao` |
| TCalendar (FMX) | `cal` | `calDataVencimento` |
