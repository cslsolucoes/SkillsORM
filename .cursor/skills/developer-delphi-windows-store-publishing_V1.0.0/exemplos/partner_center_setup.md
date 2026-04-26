# Guia Partner Center — Criar Conta, Reservar Nome e Configurar Package Identity

> **AVISO:** Validar requisitos atuais em `partner.microsoft.com` antes de
> executar — este guia pode nao refletir mudancas recentes de politica.

---

## Parte 1 — Criar Conta no Partner Center

### Passo 1.1 — Acessar o registro

URL: `https://partner.microsoft.com/dashboard/registration`

Voce precisara de uma **conta Microsoft** (pessoal ou corporativa / Azure AD).
Se ainda nao tiver, criar em `https://account.microsoft.com`.

### Passo 1.2 — Escolher tipo de conta

**Individual (USD 19):**
- Selecionar "Individual / sole proprietor"
- Usar nome pessoal
- Verificacao via email e cartao de credito
- Ideal para: desenvolvedores independentes, freelancers

**Company (USD 99):**
- Selecionar "Business"
- Exige **numero DUNS** da empresa
  - Obter DUNS gratuito: `https://www.dnb.com/duns-number/get-a-duns.html`
  - Prazo: 1 a 5 dias uteis para aprovacao do DUNS
- Verificacao adicional por equipe da Microsoft (pode levar dias)
- Ideal para: ISVs, empresas, distribuidores de software B2B

### Passo 1.3 — Preencher dados da conta

Campos obrigatorios:
- Nome do Publisher (como aparecera na Store)
- Email de contato
- Pais/regiao (define moeda e metodos de pagamento disponiveis)
- Informacoes fiscais (formulario W-8 ou W-9 dependendo do pais)

### Passo 1.4 — Pagar a taxa de registro

- Taxa unica, nao recorrente
- Aceita cartao de credito/debito ou PayPal
- Apos pagamento: conta ativada imediatamente (Individual) ou apos verificacao (Company)

---

## Parte 2 — Reservar Nome do App

> **CRITICO:** Reservar o nome ANTES de qualquer build do MSIX.
> O nome reservado determina o `Package/Identity/Name` do pacote.

### Passo 2.1 — Criar novo produto

1. Acessar: `https://partner.microsoft.com/dashboard/products`
2. Clicar em **+ New product**
3. Selecionar **App**

### Passo 2.2 — Escolher o nome

```
Nome sugerido: GestorERP
(Sera verificado se ja esta em uso na Store global)
```

- O nome deve ser unico na Microsoft Store mundial
- Pode reservar ate 10 nomes por conta
- Nomes reservados ficam disponiveis por 1 ano sem publicacao

### Passo 2.3 — Confirmar reserva

- Clicar em **Reserve product name**
- Se aceito: o sistema cria o produto e gera o **Package Identity**
- Se recusado: o nome ja esta em uso — escolher outro

---

## Parte 3 — Obter Package Identity

Apos a reserva bem-sucedida:

### Passo 3.1 — Localizar os valores

**Caminho no Partner Center:**
```
Apps and games
  → [Seu app: GestorERP]
    → Product management
      → Product Identity
```

### Passo 3.2 — Copiar os valores

Voce vera algo como:

| Campo | Exemplo de valor |
|-------|-----------------|
| Package/Identity/Name | `12345EmpresaLTDA.GestorERP` |
| Package/Identity/Publisher | `CN=Empresa LTDA, O=Empresa LTDA, C=BR, SerialNumber=0123456789` |
| Package/Identity/PublisherId | `xb1c2d3e4f5g` (informativo) |

> **COPIAR EXATAMENTE — sem espacos extras, sem alterar maiusculas/minusculas.**

---

## Parte 4 — Configurar o .dproj com os Valores do Partner Center

### Passo 4.1 — Abrir o arquivo .dproj

O arquivo fica na raiz do projeto (ex.: `GestorERP.dproj`).
Editar em editor de texto (nao fechar no RAD Studio antes).

### Passo 4.2 — Localizar o PropertyGroup de Release Win64

Procurar por:
```xml
<PropertyGroup Condition="'$(Config)'=='Release' and '$(Platform)'=='Win64'">
```

### Passo 4.3 — Inserir os valores de Package Identity

```xml
<PropertyGroup Condition="'$(Config)'=='Release' and '$(Platform)'=='Win64'">
  <!-- Valores copiados EXATAMENTE do Partner Center -->
  <!-- Partner Center: Apps and games > Seu app > Product management > Product Identity -->
  <MSIX_PackageIdentityName>12345EmpresaLTDA.GestorERP</MSIX_PackageIdentityName>
  <MSIX_PackagePublisher>CN=Empresa LTDA, O=Empresa LTDA, C=BR, SerialNumber=0123456789</MSIX_PackagePublisher>

  <!-- Versao: Major.Minor.Build.0 (quarto componente SEMPRE 0 na Store) -->
  <MSIX_PackageVersion>1.0.0.0</MSIX_PackageVersion>

  <!-- Nome de exibicao (pode diferir do Identity Name) -->
  <MSIX_PackageDisplayName>GestorERP</MSIX_PackageDisplayName>

  <!-- Nome do publisher para exibicao -->
  <MSIX_PackagePublisherDisplayName>Empresa LTDA</MSIX_PackagePublisherDisplayName>
</PropertyGroup>
```

### Passo 4.4 — Salvar e compilar

```batch
rem Build Release Win64
dcc64 GestorERP.dpr
```

Verificar que o MSIX gerado contem a identity correta:
- Abrir o .msix (e um ZIP) e inspecionar `AppxManifest.xml`
- Conferir `<Identity Name="..." Publisher="..." Version="..." />`

### Passo 4.5 — Executar WACK antes de submeter

```batch
rem Executar Windows App Certification Kit
appcert.exe test ".\Output\GestorERP.msix" "C:\Temp\wack_report.xml"
```

Corrigir TODOS os erros antes de prosseguir para o Partner Center.

---

## Resumo do Fluxo

```
[Partner Center] Criar conta
        |
        v
[Partner Center] Reservar nome do app
        |
        v
[Partner Center] Copiar Package Identity
        |
        v
[.dproj] Colar MSIX_PackageIdentityName e MSIX_PackagePublisher
        |
        v
[RAD Studio] Compilar Release Win64 → MSIX
        |
        v
[WACK] Certificar → corrigir erros
        |
        v
[Partner Center] Criar submission → Upload MSIX → Preencher metadados → Submit
```
