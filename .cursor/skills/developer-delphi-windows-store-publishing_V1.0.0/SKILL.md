---
name: developer-delphi-windows-store-publishing
description: Publicação na Microsoft Store — Partner Center, Package Identity, metadados, WACK, staged rollout, TWindowsStore, workflow completo de submissão.
model: sonnet
version: 1.0.0
created: 2026-04-11
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-windows-store-publishing_V1.0.0

**Família:** L — Windows Store / Desktop Publishing
**Versão:** 1.0.0
**Data:** 2026-04-11
**Pré-requisito:** `developer-delphi-windows-msix_V1.0.0` (SP-L1 — MSIX funcional e WACK passando)

> **AVISO IMPORTANTE:** Políticas da Microsoft Store mudam frequentemente.
> Validar requisitos atuais em `partner.microsoft.com` antes de submeter —
> este guia pode não refletir mudanças recentes de política.

---

## Escopo

Esta skill cobre o ciclo completo de publicação de aplicações Delphi na
Microsoft Store: criação de conta no Partner Center, configuração de identidade
de pacote, preenchimento de metadados, classificação IARC, staged rollout,
compras in-app com `TWindowsStore`, workflow de publicação e atualização de
versões existentes.

---

## 1. Partner Center — Conta e Registro

### URLs principais

| Ação | URL |
|------|-----|
| Dashboard principal | `https://partner.microsoft.com/dashboard` |
| Registro de conta | `https://partner.microsoft.com/dashboard/registration` |
| Gestão de apps | `https://partner.microsoft.com/dashboard/products` |

### Taxa de registro (única, não recorrente)

| Tipo de conta | Taxa | Observação |
|---------------|------|------------|
| Individual | **USD 19** | Pessoa física; nome visível na Store |
| Company (Empresa) | **USD 99** | Pessoa jurídica; exige verificação DUNS |

### Individual vs. Company

**Individual:**
- Processo de verificação mais simples
- Nome pessoal aparece como Publisher na Store
- Adequado para desenvolvedores independentes

**Company:**
- Exige número **DUNS** (Dun & Bradstreet)
  - DUNS gratuito: `https://www.dnb.com/duns-number/get-a-duns.html`
  - Prazo: 1 a 5 dias úteis para aprovação
- Nome da empresa aparece como Publisher
- Obrigatório para apps empresariais/B2B e distribuidores
- Permite múltiplos desenvolvedores sob a mesma conta

### Reservar nome do app

**Fazer ANTES de qualquer build** — o nome reservado vincula o
`Package/Identity/Name` que será usado no `.dproj`.

1. Partner Center → **Apps and games** → **New product** → **App**
2. Digitar o nome desejado (único na Store global)
3. Confirmar reserva → o sistema gera o `Package Identity`

---

## 2. Obter Package Identity do Partner Center

Após reservar o nome, os valores de identidade ficam disponíveis em:

**Apps and games → Seu app → Product management → Product Identity**

### Valores a copiar

| Campo Partner Center | Campo no `.dproj` |
|---------------------|-------------------|
| `Package/Identity/Name` | `<MSIX_PackageIdentityName>` |
| `Package/Identity/Publisher` | `<MSIX_PackagePublisher>` |
| `Package/Identity/PublisherId` | (informativo; não vai no .dproj) |

### Exemplo de valores gerados pelo Partner Center

```xml
<!-- Copiar EXATAMENTE do Partner Center para o .dproj -->
<MSIX_PackageIdentityName>12345EmpresaLTDA.GestorERP</MSIX_PackageIdentityName>
<MSIX_PackagePublisher>CN=Empresa LTDA, O=Empresa LTDA, C=BR, SerialNumber=0123456789</MSIX_PackagePublisher>
```

> **Para submissao a Store:** NAO assinar o MSIX localmente com certificado
> proprio — a Microsoft assina apos a certificacao ser aprovada.
>
> **Para testes locais** com esta identity: usar certificado auto-assinado
> com mesmo `Publisher` CN (ver skill SP-L1 — MSIX).

---

## 3. Metadados Obrigatorios

### Assets visuais

| Asset | Especificacao | Obrigatorio |
|-------|--------------|-------------|
| Icone da loja | 300×300 px, PNG, fundo transparente | Sim |
| Screenshot desktop | Min. 1366×768, max. 3840×2160; ate 10 imagens | Sim (min. 1) |
| Screenshot mobile | 768×1366 (portrait) ou proporcao equivalente | Opcional |
| Arte promocional | 1920×1080 px PNG (hero art) | Recomendado |
| Logotipo Store | 50×50 px PNG | Opcional |

### Campos de texto

| Campo | Limite | Obrigatorio |
|-------|--------|-------------|
| Titulo (nome do app) | 256 caracteres | Sim |
| Titulo curto | 50 caracteres | Opcional |
| Descricao | 10.000 caracteres por idioma | Sim |
| Descricao curta | 270 caracteres | Opcional |
| Notas de versao | 1.500 caracteres por idioma | Sim (por submission) |
| Palavras-chave (ASO) | Max. 7 por idioma | Recomendado |
| URL de politica de privacidade | URL valida e acessivel | **Obrigatorio** se coleta dados |
| URL de suporte | URL do site de suporte | Recomendado |
| Categoria | Ex.: Productivity, Business | Sim |

### Localizacao

- Adicionar pelo menos `pt-BR` e `en-US` para maior alcance
- Cada idioma pode ter descricao, screenshots e notas de versao proprios

---

## 4. Classificacao de Conteudo IARC

**IARC (International Age Rating Coalition)** e obrigatorio antes de qualquer
publicacao. Sem classificacao, a Store **rejeita** a submission.

### Como preencher

1. **Apps and games → Seu app → Age ratings**
2. Clicar em **Start questionnaire**
3. Responder o questionario online (IARC — automatico)
4. O sistema gera classificacoes simultaneas para todas as regioes:
   - **ESRB** (EUA/Canada)
   - **PEGI** (Europa)
   - **USK** (Alemanha)
   - **DJCTQ** (Brasil)
   - **ACB** (Australia)
   - E outras regioes

### Classificacoes tipicas por tipo de app

| Tipo de app | ESRB esperado | PEGI esperado |
|-------------|---------------|---------------|
| Produtividade / Negocios | Everyone (E) | PEGI 3 |
| Educacional infantil | Everyone (E) | PEGI 3 |
| App com noticias | Everyone 10+ (E10+) | PEGI 7 |
| Jogo casual | Everyone (E) a Everyone 10+ | PEGI 3 a PEGI 7 |
| App com compras in-app | Everyone (E) + aviso "In-App Purchases" | PEGI 3 |

### Impacto na Store

- A classificacao afeta a visibilidade por regiao e faixa etaria
- Apps classificados como "Adults Only" nao aparecem na Store padrao
- Classificacoes incorretas podem resultar em remocao do app

---

## 5. Staged Rollout — Lancamento Gradual

O staged rollout permite distribuir uma nova versao progressivamente,
monitorando estabilidade antes de atingir 100% dos usuarios.

### Configurar no Partner Center

```
Submission → Pricing and availability → Gradual package rollout
→ Habilitar: "Roll out update gradually"
→ Definir porcentagem inicial
```

### Progressao recomendada

```
Dia 1:  10%  — monitorar crash rate e reviews por 24-48h
Dia 3:  25%  — se metricas estavel, aumentar
Dia 5:  50%  — monitorar mais 24-48h
Dia 7: 100%  — rollout completo
```

### Como monitorar

| Metrica | Onde verificar | Limiar de alerta |
|---------|---------------|-----------------|
| Crash rate | Partner Center → Health → Failures | > 2% |
| Reviews negativos | Partner Center → Reviews | Pico de 1-2 estrelas |
| Relatorios de bug | Partner Center → Insights | Anomalias |

### Como reverter

1. Partner Center → Submission → **Stop rollout**
2. Usuarios que NAO receberam o update continuam na versao anterior
3. Usuarios que ja receberam NAO fazem downgrade automatico
4. Para forcar rollback: publicar versao anterior como nova submission

---

## 6. TWindowsStore — Componente Delphi (Licenca e Compras In-App)

O componente `TWindowsStore` (paleta **Windows** no RAD Studio) permite
verificar licenca, estado de trial e solicitar compras in-app.

### CurrentApp vs CurrentAppSimulator

| Contexto | Classe a usar | Behavior |
|----------|--------------|----------|
| `{$IFDEF DEBUG}` | `CurrentAppSimulator` | Simula Store sem conta real; configura via `StoreSimulator.xml` |
| `{$IFDEF RELEASE}` | `CurrentApp` | Conecta a Store real; requer app publicado |

### Verificar licenca e trial

```pascal
uses
  Winapi.Windows,
  FMX.Platform;

// Em modo DEBUG: usar CurrentAppSimulator
// Em modo RELEASE: usar CurrentApp

{$IFDEF DEBUG}
var
  bIsActive: Boolean;
  bIsTrial: Boolean;
begin
  // Simulador — estado configuravel via StoreSimulator.xml
  bIsActive := CurrentAppSimulator.LicenseInformation.IsActive;
  bIsTrial  := CurrentAppSimulator.LicenseInformation.IsTrial;
{$ELSE}
var
  bIsActive: Boolean;
  bIsTrial: Boolean;
begin
  bIsActive := CurrentApp.LicenseInformation.IsActive;
  bIsTrial  := CurrentApp.LicenseInformation.IsTrial;
{$ENDIF}

  if bIsActive then
  begin
    if bIsTrial then
      ShowMessage('Versao trial — considere comprar a versao completa')
    else
      // Licenca valida — liberar todas as funcionalidades
  end
  else
    ShowMessage('Licenca invalida ou app nao adquirido');
end;
```

### Solicitar compra in-app

```pascal
procedure ComprarFeature(const AProductId: string);
begin
  // AProductId = ID definido no Partner Center
  // Apps and games → Seu app → In-app products
{$IFDEF DEBUG}
  CurrentAppSimulator.RequestProductPurchaseAsync(AProductId);
{$ELSE}
  CurrentApp.RequestProductPurchaseAsync(AProductId);
{$ENDIF}
end;
```

### Tipos de produtos in-app suportados

| Tipo | Descricao | Exemplo |
|------|-----------|---------|
| Durable | Compra permanente (nao consome) | Remover anuncios, upgrade premium |
| Consumable | Consome ao usar | Creditos, tokens, moedas virtuais |
| Subscription | Assinatura recorrente | Plano mensal/anual |

---

## 7. Workflow Completo de Publicacao (10 Passos)

```
Passo 1  — Partner Center: criar app, reservar nome, obter Package Identity
Passo 2  — RAD Studio: configurar .dproj com MSIX_PackageIdentityName e
           MSIX_PackagePublisher do Partner Center
Passo 3  — Build Release Win64:
             dcc64 GestorERP.dpr
             Deployment Manager → gerar MSIX
Passo 4  — WACK (Windows App Certification Kit):
             appcert.exe test "caminho\GestorERP.msix" "C:\relatorio.xml"
             Corrigir TODOS os erros antes de continuar
Passo 5  — Partner Center: "New submission" para o app
Passo 6  — Upload: arrastar o .msix para a secao "Packages" da submission
Passo 7  — Store listing: preencher descricao, screenshots, palavras-chave,
           URL de privacidade por idioma
Passo 8  — Age ratings: preencher questionario IARC
Passo 9  — Pricing and availability: definir preco (gratis, pago ou trial)
           Configurar staged rollout se desejado
Passo 10 — "Submit to the Store"
           Aguardar: 1-3 dias uteis (novos apps); updates mais rapidos
```

### Tempo estimado por fase

| Fase | Tempo estimado |
|------|---------------|
| Certificacao (novos apps) | 1 a 3 dias uteis |
| Certificacao (updates) | 1 a 2 dias uteis |
| Staged rollout completo | 7 a 14 dias (a criterio do dev) |
| Aprovacao apos correcao de rejeicao | 1 a 3 dias uteis adicionais |

---

## 8. Atualizacao de App Existente

### Incrementar versao no .dproj

```xml
<!-- Formato obrigatorio: Major.Minor.Build.0 -->
<!-- Quarto componente SEMPRE 0 na Store -->
<!-- Antes: -->
<MSIX_PackageVersion>1.0.0.0</MSIX_PackageVersion>

<!-- Depois (patch/bugfix): -->
<MSIX_PackageVersion>1.0.1.0</MSIX_PackageVersion>

<!-- Depois (minor feature): -->
<MSIX_PackageVersion>1.1.0.0</MSIX_PackageVersion>

<!-- Depois (major release): -->
<MSIX_PackageVersion>2.0.0.0</MSIX_PackageVersion>
```

> **REGRA:** A versao da nova submission DEVE ser maior que a versao
> atualmente publicada. A Store rejeita versoes iguais ou menores.

### Fluxo de update

1. Incrementar `MSIX_PackageVersion` no `.dproj`
2. Compilar build Release e gerar novo MSIX
3. Executar WACK no novo MSIX
4. Partner Center → Seu app → **New submission** (nao criar novo app!)
5. Preencher **notas de versao** (o que mudou — obrigatorio por idioma)
6. Upload do novo .msix
7. Submit

### Entrega automatica aos usuarios

- Updates chegam **automaticamente** a todos os usuarios com versao anterior
- O usuario nao precisa procurar nem re-instalar
- Apps fechados recebem o update na proxima abertura do Windows Store
- Apps abertos recebem o update no proximo fechamento/abertura

---

## 9. Checklist Pre-Submissao (Microsoft Store)

- [ ] `Package/Identity/Name` e `Publisher` no `.dproj` = valores exatos do Partner Center
- [ ] Versao no formato `Major.Minor.Build.0` (quarto componente = zero)
- [ ] Versao maior que a atualmente publicada
- [ ] WACK executado e passou sem erros criticos
- [ ] Screenshot minima: 1366×768 px desktop, pelo menos 1
- [ ] Icone da loja: 300×300 px PNG
- [ ] Politica de privacidade URL valida e acessivel (obrigatorio se app coleta dados)
- [ ] Classificacao IARC preenchida e aprovada
- [ ] Notas de versao preenchidas por idioma
- [ ] App nao usa APIs bloqueadas pela sandbox (verificado no WACK)
- [ ] Testado via sideload com o MSIX antes de submeter

---

## Arquivos desta skill

### exemplos/
- `partner_center_setup.md` — guia passo-a-passo: criar conta, reservar nome, obter Package Identity, configurar .dproj
- `store_metadata_guide.md` — guia de preenchimento de metadados e ASO (App Store Optimization)
- `windows_store_component.pas` — codigo Pascal compilavel com TWindowsStore: licenca, trial, compras in-app
- `staged_rollout.md` — configurar e monitorar rollout gradual no Partner Center
- `store_update_workflow.md` — publicar atualizacao: incrementar versao, nova submission, notas de versao

### consultas_rapidas/
- `store_assets_specs.md` — tabela completa de dimensoes e formatos de todos os assets
- `store_submission_checklist.md` — checklist 15+ itens por categoria
- `wack_errors_common.md` — erros WACK frequentes: causa e correcao
- `iarc_guide.md` — guia IARC completo: questionario, classificacoes por tipo de app
- `store_policies_summary.md` — resumo das politicas mais impactantes para apps empresariais

### templates/
- `TEMPLATE_store_release.dproj` — PropertyGroup Release Win64 com placeholders de Package Identity
- `TEMPLATE_windows_store.pas` — unit completa com interface IWindowsStoreService e TWindowsStoreService

---

## Referencias

- Partner Center: `https://partner.microsoft.com/dashboard`
- Documentacao MSIX: `https://learn.microsoft.com/windows/msix/`
- WACK: `https://learn.microsoft.com/windows/uwp/debug-test-perf/windows-app-certification-kit`
- IARC: `https://www.globalratings.com/`
- Politicas da Store: `https://learn.microsoft.com/windows/apps/publish/store-policies`
- TWindowsStore (Delphi 12): `Doc-Delphi/delphi12-topics_chm_decompiled/Using_the_WindowsStore_Component.htm`
- TWindowsStore (Delphi 13): `Doc-Delphi/delphi13-topics_chm_decompiled/Using_the_WindowsStore_Component.htm`
