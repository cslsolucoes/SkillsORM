# TStyleBook — Guia Rápido FMX

## O que é

TStyleBook é o componente que centraliza o visual (cores, bordas, fontes) de
todos os controles FMX. Um arquivo `.fsf` (FireMonkey Style File) contém o
mapa de estilos para cada tipo de controle.

## Aplicar estilo ao form

```pascal
// 1. No designer: adicionar TStyleBook ao form
//    Propriedade StyleBook do form aponta para ele

// 2. Em runtime:
StyleBook1.LoadFromFile('MeuEstilo.fsf');
Self.StyleBook := StyleBook1;  // aplica ao form
```

## Aplicar a toda a aplicação

```pascal
StyleBook1.LoadFromFile('MeuEstilo.fsf');
Application.Style := StyleBook1;  // todos os forms herdam
```

## Carregar de recurso embarcado

```pascal
// No .dproj: adicionar MeuEstilo.fsf como resource
// Tipo: STYLE, Nome: MEUESTILO (sem extensao)
StyleBook1.LoadFromResource('MEUESTILO');
Self.StyleBook := StyleBook1;
```

## Estilos padrão do Delphi

| Arquivo | Plataforma |
|---------|-----------|
| `Windows11Modern.fsf` | Windows 11 (padrão moderno) |
| `Windows.fsf` | Windows clássico |
| `CustomBlack.fsf` | Tema escuro universal |
| `MacOS.fsf` | macOS |
| `Android.fsf` | Android Material |
| `iOS.fsf` | iOS Human Interface |

**Pasta:** `C:\Program Files (x86)\Embarcadero\Studio\XX.0\Redist\styles\fmx\`

## StyleLookup — aplicar estilo por componente

```pascal
// Aplicar estilo especifico a um botao
BtnOK.StyleLookup := 'acceptbutton';       // botao verde
BtnCancel.StyleLookup := 'cancelbutton';   // botao vermelho
BtnClear.StyleLookup := 'clearbuttonStyle'; // botao transparente
BtnSearch.StyleLookup := 'searchbutton';
```

## Inspecionar estilos no runtime

```pascal
// Ver qual estilo esta sendo aplicado a um controle
var StyleName := BtnOK.StyleLookup;
// String vazia = usando estilo padrao do StyleBook
```

## Criar estilo inline (sem arquivo .fsf)

```pascal
// Apenas para casos simples — preferir .fsf
var Rec := TRectangle.Create(Self);
Rec.Fill.Color   := $FF2C3E50;
Rec.Stroke.Color := $FF1A252F;
Rec.XRadius := 6;
// Nao usa StyleBook — estilo definido diretamente
```

## Armadilhas

| Armadilha | Solução |
|-----------|---------|
| StyleBook aplicado no form não afeta filhos criados em runtime | Definir `Parent` antes de `StyleBook` |
| `Application.Style` muda TODOS os forms abertos | Usar `Form.StyleBook` para escopo limitado |
| Arquivo .fsf não encontrado → AV silencioso | Verificar `TFile.Exists` antes de `LoadFromFile` |
| Estilo customizado some após rebuild | Embutir como resource, não como arquivo externo |
