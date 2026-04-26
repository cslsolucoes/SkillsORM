# Templates de Form Units — VCL / FMX / LCL

**Localização:** `.cursor/Templates/form-units/`

Templates para gerar pares de arquivos de formulário Delphi e FPC/Lazarus.
O nome dos arquivos gerados é igual ao nome da `unit` declarada no `.pas`.

---

## Templates disponíveis

| Template (`.template`) | Arquivo gerado | Framework |
| ---------------------- | -------------- | --------- |
| `{UNIT_NAME}.dfm.template` | `{UnitName}.dfm` | VCL Delphi — resource de formulario |
| `{UNIT_NAME}.vcl.pas.template` | `{UnitName}.pas` | VCL Delphi — unit Pascal |
| `{UNIT_NAME}.fmx.template` | `{UnitName}.fmx` | FMX Delphi — resource de formulario |
| `{UNIT_NAME}.fmx.pas.template` | `{UnitName}.pas` | FMX Delphi — unit Pascal |
| `{UNIT_NAME}.lfm.template` | `{UnitName}.lfm` | LCL FPC/Lazarus — resource de formulario |
| `{UNIT_NAME}.lcl.pas.template` | `{UnitName}.pas` | LCL FPC/Lazarus — unit Pascal |

> O `.pas` é nomeado pelo `{UNIT_NAME}` — o sufixo `.vcl.`, `.fmx.` ou `.lcl.` faz parte
> apenas do nome do template para distingui-los, NAO aparece no arquivo gerado.

---

## Diferenças entre os frameworks

| Aspecto | VCL | FMX | LCL (FPC) |
| ------- | --- | --- | --------- |
| Resource | `.dfm` | `.fmx` | `.lfm` |
| Diretiva R | `{$R *.dfm}` | `{$R *.fmx}` | `{$R *.lfm}` |
| Uses principais | `Vcl.Forms, Vcl.Controls, Vcl.Graphics, Vcl.Dialogs` | `FMX.Forms, FMX.Controls, FMX.Graphics, FMX.Dialogs` | `Forms, Controls, Graphics, Dialogs` |
| Uses Win32 | `Winapi.Windows, Winapi.Messages` | — | — |
| Modo FPC | — | — | `{$mode objfpc}{$H+}` |
| Resource de layout | `LCLVersion` no `.lfm` | `FormFactor` no `.fmx` | `LCLVersion` no `.lfm` |

---

## Placeholders

| Placeholder | Descrição | Exemplo |
| ----------- | --------- | ------- |
| `{UNIT_NAME}` | Nome da unit (igual ao nome do arquivo `.pas`) | `ufrm.Connections` |
| `{FORM_CLASS}` | Classe do formulario **sem** o prefixo `T` | `frmConnections` |
| `{FORM_INSTANCE}` | Nome da variavel global de instancia | `frmConnections` |
| `{FORM_CAPTION}` | Titulo da janela (propriedade `Caption`) | `Connections` |
| `{LCL_VERSION}` | Versao do LCL (apenas `.lfm`) | `4.4.0.0` |

---

## Como gerar

### Via script (automático)

```powershell
# VCL
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-form-unit.ps1" `
    -UnitName "ufrm.Connections" -FormClass "frmConnections" `
    -FormCaption "Connections" -Framework VCL -OutputDir "src\Views"

# FMX
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-form-unit.ps1" `
    -UnitName "ufrm.Main" -FormClass "frmMain" `
    -FormCaption "Main" -Framework FMX -OutputDir "src\Views"

# LCL (FPC/Lazarus)
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-form-unit.ps1" `
    -UnitName "ufrm.Main" -FormClass "frmMain" `
    -FormCaption "Main" -Framework LCL -OutputDir "src\Views"
```

### Manual

1. Copiar os dois templates correspondentes ao framework (`{UNIT_NAME}.dfm.template` +
   `{UNIT_NAME}.vcl.pas.template` para VCL, por exemplo) para o diretorio de destino.
2. Renomear para `{UnitName}.dfm` e `{UnitName}.pas`.
3. Substituir todos os `{PLACEHOLDER}` pelos valores reais.

---

## Versão interna (ficheiro)

| Campo | Valor |
| ----- | ----- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.0 (31/03/2026): Criação — templates VCL (.dfm+.pas), FMX (.fmx+.pas) e LCL (.lfm+.pas).
