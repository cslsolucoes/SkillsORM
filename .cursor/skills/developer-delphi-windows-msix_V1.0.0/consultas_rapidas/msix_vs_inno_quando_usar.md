# MSIX vs Inno Setup vs ClickOnce — Tabela Comparativa

## Tabela de decisao (7+ criterios)

| Criterio | MSIX | Inno Setup | ClickOnce |
|----------|------|------------|-----------|
| **Microsoft Store** | Sim — formato nativo exigido | Nao | Nao |
| **Update automatico silencioso** | Sim — nativo, sem intervencao | Manual (usuario baixa novo installer) | Sim — mas requer URL de publicacao |
| **Sandbox / containerizacao** | Sim — filesystem e registry virtualizados | Nao — acesso direto ao sistema | Parcial — restricoes de trust zone |
| **Acesso irrestrito ao sistema** | Com `runFullTrust` (requer aprovacao Store) | Sim — total | Nao — sandbox de trust zone |
| **Rollback automatico** | Sim — versao anterior e preservada | Nao — requer backup manual | Sim — versao anterior disponivel |
| **Instalacao sem privilegios de Admin** | Sim — user-scope install | Nao tipicamente (pode ser configurado) | Sim |
| **Tamanho do pacote** | Maior — autocontido (todas DLLs incluidas) | Menor — instala no system32/GAC | Medio — can use prerequisites |
| **Complexidade de configuracao** | Alta — manifest, assets, deployment manager | Baixa — script Pascal simples | Media — configuracao no Visual Studio |
| **Suporte nativo no Delphi/RAD Studio** | Sim — RAD Studio 11 Alexandria+ | Sim — via script externo | Sim — via IDE |
| **Compatibilidade com Windows antigo** | Windows 10 1709+ (MSIX pleno: 1809+) | Windows XP+ | Windows XP+ (com .NET) |
| **Custo de certificado** | OV/EV obrigatorio (USD 200-500/ano); Store: incluso | OV/EV ou auto-assinado; pode distribuir sem cert | OV/EV ou auto-assinado |
| **Atualizacoes delta (parcial)** | Sim — apenas blocos modificados | Nao — reinstalacao completa | Sim |
| **Suporte a multiplos usuarios na maquina** | Sim — instalacao por usuario ou por maquina | Sim | Sim |

---

## Quando escolher cada um

### Escolher MSIX quando:

- O app sera distribuido pela **Microsoft Store**
- Updates automaticos silenciosos sao criticos para o negocio
- O cliente tem Windows 10 1809+ garantido
- Quer isolamento via containerizacao (evitar conflitos de DLL)
- Precisa de instalacao sem privilegios de admin para usuarios corporativos

### Escolher Inno Setup quando:

- Precisa de **compatibilidade com Windows 7/8** ou versoes antigas do Windows 10
- O app precisa de **acesso irrestrito ao sistema** (drivers, serviços Windows, escrita em `C:\Program Files`)
- Quer **menor complexidade de configuracao e manutencao**
- O app instala servicos Windows (SCM), drivers, ou modifica o registry de forma extensiva
- Nao tem recurso para gerenciar certificados OV/EV

### Escolher ClickOnce quando:

- App **.NET** ou **COM** distribuido em rede corporativa interna
- Precisa de atualizacoes automaticas sem Store
- Ambiente controlado onde as politicas de trust estao configuradas
- Usa Visual Studio como IDE principal (integracao nativa)

---

## Combinacoes possiveis

| Cenario | Solucao recomendada |
|---------|---------------------|
| Distribuicao publica + updates automaticos | MSIX via Microsoft Store |
| Distribuicao publica sem Store + suporte a Windows antigo | Inno Setup + signtool (OV cert) |
| Ambos (Store + instalador classico) | MSIX para Store + Inno Setup para distribuicao direta |
| Corporativo interno + updates | ClickOnce ou MSIX sideload |
| App legado incompativel com MSIX completo | Sparse Package (MSIX parcial) |
| Desenvolvimento/testes internos | MSIX sideload com cert auto-assinado |

---

## Resumo executivo (para apresentar ao time)

```
Microsoft Store obrigatorio?       → MSIX (sem alternativa)
Windows < 10 1809 nos clientes?    → Inno Setup
App escreve em C:\Windows ou SCM?  → Inno Setup
Update automatico e critico?       → MSIX ou ClickOnce
Complexidade minima?               → Inno Setup
Melhor experiencia usuario moderno? → MSIX
```
