# Workflow de Atualizacao — Publicar Nova Versao de App Existente

Este guia cobre o fluxo completo para publicar uma atualizacao de versao
de um app ja existente na Microsoft Store.

> **AVISO:** Validar requisitos em `partner.microsoft.com` — interface e
> politicas podem ter mudado desde a criacao deste guia.

---

## Regras de Versionamento

### Formato obrigatorio

```
Major.Minor.Build.Revision
```

**Regras da Store:**
- Quarto componente (Revision) SEMPRE = 0
- A nova versao DEVE ser numericamente maior que a publicada
- A Store rejeita versoes iguais ou menores

### Exemplos de incremento

| Tipo de mudanca | Antes | Depois |
|----------------|-------|--------|
| Bugfix / patch | 1.0.0.0 | 1.0.1.0 |
| Nova feature (minor) | 1.0.1.0 | 1.1.0.0 |
| Reescrita / breaking change | 1.1.0.0 | 2.0.0.0 |

### Convencao recomendada (SemVer adaptado)

```
Major = mudancas incompativeis / redesign
Minor = novas funcionalidades (backward compatible)
Build = bugfixes e patches
Revision = sempre 0 (exigido pela Store)
```

---

## Parte 1 — Incrementar Versao no .dproj

### Passo 1.1 — Localizar a propriedade de versao

Abrir `GestorERP.dproj` em editor de texto e localizar:

```xml
<PropertyGroup Condition="'$(Config)'=='Release' and '$(Platform)'=='Win64'">
  <MSIX_PackageVersion>1.0.0.0</MSIX_PackageVersion>
  ...
</PropertyGroup>
```

### Passo 1.2 — Incrementar a versao

```xml
<!-- ANTES (versao publicada) -->
<MSIX_PackageVersion>1.0.0.0</MSIX_PackageVersion>

<!-- DEPOIS (bugfix) -->
<MSIX_PackageVersion>1.0.1.0</MSIX_PackageVersion>
```

### Passo 1.3 — Verificar consistencia

Conferir que a versao no `.dproj` esta sincronizada com outros locais:
- `AppxManifest.xml` (se existir na solucao)
- String de versao exibida no About do app
- Release notes / changelog interno

---

## Parte 2 — Compilar e Gerar o MSIX de Update

### Passo 2.1 — Limpar artefatos anteriores

```batch
rem Limpar output anterior para evitar mistura de binarios
del /Q Output\Win64\Release\*.msix
del /Q Output\Win64\Release\*.exe
```

### Passo 2.2 — Compilar Release Win64

```batch
rem Compilar com dcc64
dcc64 GestorERP.dpr
```

Ou via RAD Studio IDE:
- **Build Configuration:** Release
- **Platform:** Windows 64-bit
- **Project → Build** (Shift+F9)

### Passo 2.3 — Gerar o MSIX

Via Deployment Manager no RAD Studio:
1. **Project → Deployment**
2. Verificar que todos os arquivos necessarios estao incluidos
3. **Project → Deploy**

Ou via linha de comando (se configurado):
```batch
rem MakeAppx empacota os arquivos em MSIX
MakeAppx.exe pack /d "Output\Win64\Release\AppxFiles" /p "Output\GestorERP_1.0.1.0.msix"
```

---

## Parte 3 — Executar WACK no Novo MSIX

**Obrigatorio antes de qualquer submission.**

```batch
rem Windows App Certification Kit
appcert.exe test "Output\GestorERP_1.0.1.0.msix" "C:\Temp\wack_report_1.0.1.0.xml"
```

- Corrigir TODOS os erros criticos antes de prosseguir
- Warnings podem ser documentados mas nao bloqueiam a submission
- Ver `consultas_rapidas/wack_errors_common.md` para erros frequentes

---

## Parte 4 — Criar Nova Submission no Partner Center

### CRITICO: Usar "New submission" no app existente

**NAO criar um novo produto** — isso geraria um app diferente na Store.

**Caminho correto:**
```
Apps and games
  → GestorERP [app existente]
    → + New submission
```

### Passo 4.1 — Configurar pacotes

1. Navegar ate **Packages** na submission
2. Remover o MSIX da versao anterior (opcional — a Store mantem historico)
3. Arrastar o novo `.msix` para a area de upload
4. Aguardar upload e validacao automatica pela Store (pode levar minutos)

### Passo 4.2 — Atualizar notas de versao (obrigatorio)

**Caminho:**
```
Submission → Store listings → [Idioma] → What's new in this version
```

Preencher para CADA idioma da lista:

```
pt-BR:
v1.0.1.0 — Atualizacao de correcao
- Corrigido: travamento ao abrir relatorio de vendas com mais de 1.000 registros
- Corrigido: erro de calculo de ICMS para produtos com ST em SP e RJ
- Melhorado: desempenho da consulta de estoque (40% mais rapido)

en-US:
v1.0.1.0 — Bug Fix Release
- Fixed: crash when opening sales report with over 1,000 records
- Fixed: ICMS calculation error for products with tax substitution
- Improved: inventory query performance (40% faster)
```

### Passo 4.3 — Verificar metadados

- Nao e necessario alterar screenshots ou descricao se nao mudou
- Atualizar apenas o que efetivamente mudou
- Se houver nova feature, atualizar descricao e considerar nova screenshot

### Passo 4.4 — Configurar staged rollout (recomendado)

Para updates com mudancas significativas:
- **Pricing and availability → Gradual package rollout → Habilitar**
- Porcentagem inicial: 10%
- Ver `exemplos/staged_rollout.md` para o guia completo

### Passo 4.5 — Submeter

- Revisar o resumo da submission
- Clicar em **Submit to the Store**

---

## Parte 5 — Entrega Automatica aos Usuarios

Apos aprovacao da certification:

| Comportamento | Detalhe |
|--------------|---------|
| Entrega automatica | Sim — usuarios recebem sem acao manual |
| Download em background | Windows Update Service baixa em segundo plano |
| Instalacao | Ocorre quando o app nao esta em uso |
| Notificacao ao usuario | Icone atualizado na Store; sem pop-up invasivo |
| Tempo ate receber | Horas a 1-2 dias (Microsoft distribui por datacenter) |

> O usuario nao precisa abrir a Store ou clicar em "Atualizar".
> O Windows gerencia o ciclo automaticamente.

---

## Parte 6 — Verificar Sucesso da Atualizacao

### 6.1 — Confirmar versao publicada

**Partner Center:**
```
Apps and games → GestorERP → Overview
→ Current published version: 1.0.1.0
```

### 6.2 — Monitorar metricas pos-update

Durante os primeiros 2-3 dias:
- **Health → Failures:** conferir que crash rate nao aumentou
- **Reviews:** monitorar reviews recentes para identificar regressoes
- **Acquisitions:** verificar se volume de instalacoes continua estavel

### 6.3 — Testar o update em maquina de teste

Antes de considerar o rollout 100% bem-sucedido:
1. Em uma maquina com a versao anterior instalada
2. Abrir Microsoft Store → atualizar o app
3. Confirmar que a versao nova roda sem problemas

---

## Checklist de Update

- [ ] Versao incrementada no .dproj (formato X.X.X.0)
- [ ] Nova versao e numericamente maior que a publicada
- [ ] Build Release Win64 compilado com sucesso
- [ ] MSIX gerado sem erros
- [ ] WACK executado e aprovado sem erros criticos
- [ ] "New submission" criada no app existente (nao novo produto)
- [ ] Novo MSIX carregado na submission
- [ ] Notas de versao preenchidas em TODOS os idiomas suportados
- [ ] Staged rollout configurado (se aplicavel)
- [ ] Submission enviada com sucesso
- [ ] Monitorar metricas nas primeiras 48h apos aprovacao
