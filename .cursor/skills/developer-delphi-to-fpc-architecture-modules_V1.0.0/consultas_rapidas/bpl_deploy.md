# BPL Runtime — Deploy e Carregamento Dinâmico

**Skill:** `developer-delphi-to-fpc-architecture-modules_V1.0.0`
**Data:** 2026-04-11

---

## O que é um BPL

BPL (Borland/Embarcadero Package Library) é uma DLL especializada do Delphi:
- Contém units Delphi compiladas em formato binário.
- Compartilha o mesmo RTL e VCL/FMX com o aplicativo host.
- Gerado com extensão `.bpl` (Windows) ou `.so` (Linux/Android).

---

## Static vs Dynamic Linking

| Aspecto | Static (sem runtime packages) | Dynamic (com runtime packages) |
|---------|-------------------------------|-------------------------------|
| **Tamanho do .exe** | Grande (inclui todo o código) | Pequeno (código nos .bpl) |
| **Dependências em deploy** | Apenas o .exe | .exe + todos os .bpl requeridos |
| **Versão de runtime** | Isolada por app | Compartilhada entre apps |
| **Plugins dinâmicos** | Não suportado | Sim (LoadPackage) |
| **Configuração IDE** | Link with runtime packages = OFF | Link with runtime packages = ON |

**Onde configurar:**
`Project → Options → Packages → Runtime packages → "Link with runtime packages"`

---

## Estrutura de um Package (.dpk)

```pascal
package MeuPlugin;

{$DESCRIPTION 'Plugin de Relatórios GestorERP'}
{$RUNONLY}          // runtime package (não design-time)
{$IMPLICITBUILD ON}

requires
  rtl,              // RTL do Delphi (obrigatório)
  vcl;              // VCL (se usar componentes visuais)

contains
  uPlugin.Interfaces in 'uPlugin.Interfaces.pas',
  uRelatorio.Impl in 'uRelatorio.Impl.pas';

end.
```

**Tipos de package pela diretiva:**
- `{$RUNONLY}` — runtime package
- `{$DESIGNONLY}` — design-time package (só no IDE)
- Sem diretiva — pode ser ambos

---

## Carregamento dinâmico com LoadPackage

```pascal
uses SysUtils, Windows;

procedure CarregarPlugin(const ACaminho: string);
var
  H: HMODULE;
  CreatePlugin: function: IPlugin; stdcall;
begin
  // 1. Carregar o BPL (inicializa units, chama initialization)
  H := LoadPackage(ACaminho);
  if H = 0 then
    raise Exception.CreateFmt('Falha ao carregar: %s [%s]',
      [ACaminho, SysErrorMessage(GetLastError)]);

  // 2. Obter ponteiro da função factory exportada
  @CreatePlugin := GetProcAddress(H, 'CreatePlugin');
  if not Assigned(CreatePlugin) then
  begin
    UnloadPackage(H);  // sempre descarregar se falhar
    raise Exception.CreateFmt('"%s" não exporta CreatePlugin', [ACaminho]);
  end;

  // 3. Usar o plugin via interface
  FPlugin := CreatePlugin;

  // 4. Guardar handle para descarregar depois
  FHandle := H;
end;

procedure DescarregarPlugin;
begin
  // ORDEM OBRIGATÓRIA: liberar interfaces ANTES de descarregar o BPL
  // (interfaces apontam para código dentro do BPL)
  FPlugin := nil;                    // libera referência da interface
  UnloadPackage(FHandle);           // chama finalization + FreeLibrary
  FHandle := 0;
end;
```

---

## Exportar função do plugin no BPL

```pascal
// No arquivo .pas dentro do package:
unit uRelatorio.Impl;

interface
uses uPlugin.Interfaces;

function CreatePlugin: IPlugin; stdcall;

implementation

type
  TRelatorioPlugin = class(TInterfacedObject, IPlugin)
    ...
  end;

function CreatePlugin: IPlugin; stdcall;
begin
  Result := TRelatorioPlugin.Create;
end;

exports
  CreatePlugin;   // torna a função visível via GetProcAddress

end.
```

---

## Deploy — checklist de arquivos

Para um app que usa runtime packages, distribuir junto:

```
MeuApp.exe
rtl280.bpl          ← RTL do Delphi (versão corresponde ao Delphi usado)
vcl280.bpl          ← VCL (se usar componentes visuais)
vclimg280.bpl       ← imagens VCL (se usar TImage, etc.)
MeuPlugin_1_0.bpl   ← plugin próprio
```

**Onde colocar os BPLs:**
1. Mesma pasta do .exe (recomendado para plugins próprios).
2. Pasta do sistema Windows (não recomendado para plugins de app).
3. PATH do sistema (para BPLs compartilhados entre múltiplos apps).

---

## Versionamento de BPL — evitar "DLL Hell"

| Prática | Exemplo |
|---------|---------|
| Incluir versão no nome do arquivo | `GestorPlugin_2_1.bpl` |
| Incluir versão do Delphi | `GestorPlugin_2_1_d28.bpl` |
| Manter interface estável entre versões | Não remover/reordenar métodos da interface exportada |
| Documentar versão mínima do host | README: "Requer GestorERP 2.0 ou superior" |

---

## LoadPackage vs LoadLibrary

| | LoadPackage | LoadLibrary |
|--|-------------|-------------|
| **Para** | BPL (Delphi packages) | DLL genérica |
| **Inicializa** | Seção `initialization` das units | DllMain |
| **Finaliza** | Seção `finalization` das units | DllMain (DLL_PROCESS_DETACH) |
| **Compartilha RTL** | Sim (com o host Delphi) | Não (RTL separado na DLL) |
| **GetProcAddress** | Funciona da mesma forma | Funciona da mesma forma |

**Regra:** use `LoadPackage` para BPLs Delphi; `LoadLibrary` para DLLs de outros compiladores ou linguagens.
