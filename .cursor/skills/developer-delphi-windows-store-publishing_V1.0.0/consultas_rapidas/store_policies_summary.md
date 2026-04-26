# Politicas da Microsoft Store — Resumo para Apps Empresariais

> **AVISO CRITICO:** As politicas da Microsoft Store mudam frequentemente
> e sem aviso previo. Este resumo pode estar desatualizado.
> **SEMPRE verificar as politicas vigentes em:**
> `https://learn.microsoft.com/windows/apps/publish/store-policies`
> antes de cada submissao.

---

## Privacidade e Coleta de Dados

### Politica de privacidade obrigatoria

**Quando e obrigatorio ter URL de politica de privacidade:**
- App coleta qualquer dado pessoal (nome, email, telefone, etc.)
- App usa localizacao do usuario
- App acessa camera, microfone ou outros sensores
- App transmite dados para servidores externos
- App usa autenticacao (login de usuario)

**Requisitos da politica de privacidade:**
- URL deve ser publica e acessivel sem login
- Deve descrever quais dados sao coletados
- Deve descrever como os dados sao usados e armazenados
- Deve descrever com quem os dados sao compartilhados
- Deve incluir informacoes de contato para solicitacoes de privacidade

### LGPD e compliance brasileiro

Para apps publicados no Brasil com coleta de dados de residentes brasileiros:
- Obrigatorio informar a base legal para o tratamento (LGPD Art. 7)
- Direito de acesso, correcao e exclusao dos dados
- Nomear Encarregado de Dados (DPO) se processamento em larga escala

### Dados de menores

- Apps que coletam dados de menores de 13 anos (EUA: COPPA) exigem
  consentimento parental verificavel
- Recomendado: nao coletar dados de menores; exigir que o usuario confirme
  ter 13+ anos ou ter consentimento parental

---

## Compras e Monetizacao

### Compras in-app

- Todos os produtos digitais vendidos dentro do app DEVEM usar o sistema
  de compras da Microsoft Store
- **Proibido:** direcionar o usuario para site externo para comprar a mesma
  funcionalidade que poderia ser vendida in-app
- **Permitido:** vender servicos fisicos ou do mundo real via meios externos
  (ex.: consultoria, hardware)

### Taxas da Store

- A Microsoft retém uma porcentagem das vendas (verificar taxa atual em partner.microsoft.com)
- Apps gratuitos com compras in-app tambem estao sujeitos as taxas
- Existe programa de reducao de taxa para apps com receita abaixo de limite anual

### Trial e freemium

- Periodo de trial deve ser claro para o usuario
- Funcionalidades bloqueadas apos trial devem ser claramente indicadas
- Proibido limitar funcionalidades compradas sem notificacao ao usuario

---

## Comportamento do App

### APIs e Sandbox

| Proibido | Permitido |
|---------|-----------|
| Chamar APIs de kernel nao autorizadas | WinRT APIs, Windows App SDK |
| Modificar o registro do sistema fora do escopo do app | Escrita em `HKCU\Software\<AppName>` |
| Instalar servicos do Windows sem consentimento | Servicos declarados no manifest e com consentimento |
| Elevar privilegios silenciosamente (UAC bypass) | Solicitar elevacao via manifest com aviso ao usuario |
| Comunicar com outros processos sem capacidade declarada | IPC dentro das capacidades declaradas |

### Estabilidade e desempenho

- App nao pode travar ou consumir recursos excessivos em segundo plano
  sem necessidade declarada
- Apps com crash rate alto podem ser suspensos da Store
- Background tasks devem ser declaradas no manifest e ter escopo limitado

### Atualizacoes automaticas

- Updates chegam via Windows Update / Store automaticamente
- Proibido: implementar mecanismo de auto-update proprio que bypass a Store
  para apps distribuidos pela Store
- Permitido: verificar atualizacoes e direcionar o usuario para a Store

---

## Conteudo Proibido

| Categoria | Detalhe |
|-----------|---------|
| Malware / spyware | Zero tolerancia; resulta em remocao imediata e banimento da conta |
| Conteudo sexual explicito | Proibido na Store padrao |
| Conteudo que promova violencia real | Proibido |
| Violacao de direitos autorais | Conteudo de terceiros sem licenca |
| Engano ao usuario | Screenshots que nao representam o app real |
| Phishing | Simular outros apps ou servicos para coletar credenciais |
| Conteudo ilegal | Varia por mercado; a Microsoft aplica restricoes por regiao |

---

## Dados e APIs Sensiveis

### Capacidades que exigem declaracao no manifest

```xml
<!-- Exemplos de capabilities que exigem declaracao -->
<Capabilities>
  <Capability Name="internetClient" />        <!-- Acesso a internet -->
  <Capability Name="privateNetworkClientServer" /> <!-- Rede local -->
  <DeviceCapability Name="webcam" />          <!-- Camera -->
  <DeviceCapability Name="microphone" />      <!-- Microfone -->
  <DeviceCapability Name="location" />        <!-- Localizacao GPS -->
</Capabilities>
```

### Capacidades restritas (restricted capabilities)

Exigem aprovacao previa da Microsoft antes de submeter:

| Capability | Uso | Processo de aprovacao |
|-----------|-----|----------------------|
| `rescap:broadFileSystemAccess` | Acesso irrestrito ao sistema de arquivos | Solicitar via Partner Center |
| `rescap:packageManagement` | Instalar outros packages | Aprovacao necessaria |
| `rescap:backgroundSpatialPerception` | AR/VR background | Aprovacao necessaria |

---

## Politicas por Mercado

| Mercado | Restricoes especificas |
|---------|----------------------|
| China | Conteudo politico sensivel; app pode ser removido sem aviso |
| Russia | Dados de cidadaos russos devem ser armazenados em servidores russos (lei local) |
| Korea | Classificacao GRAC obrigatoria para jogos |
| Alemanha | Conteudo classificado USK 18 nao disponivel sem verificacao de idade |
| Todos | Compliance com leis locais de privacidade e consumidor |

---

## O que Fazer se o App for Removido

1. Ler o email de notificacao com o motivo especifico
2. Corrigir o problema identificado
3. Se discordar: usar o processo de apelacao no Partner Center
4. Resubmeter com descricao das correcoes realizadas
5. Tempos de revisao apos apelacao: 3 a 7 dias uteis

---

## Links de Politicas Oficiais

- Store Policies: `https://learn.microsoft.com/windows/apps/publish/store-policies`
- Developer Code of Conduct: `https://learn.microsoft.com/windows/apps/publish/store-developer-code-of-conduct`
- Restricted capabilities: `https://learn.microsoft.com/windows/uwp/packaging/app-capability-declarations`
- Privacy guidelines: `https://learn.microsoft.com/windows/apps/publish/privacy-policy-guidelines`
- Advertising policies: `https://learn.microsoft.com/windows/apps/publish/store-policies#10-advertising`
