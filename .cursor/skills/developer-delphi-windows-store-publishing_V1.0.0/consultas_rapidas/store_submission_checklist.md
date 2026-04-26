# Checklist de Submissao — Microsoft Store

Use este checklist antes de cada nova submission. Marcar todos os itens
antes de clicar em "Submit to the Store".

> **AVISO:** Politicas da Store mudam frequentemente.
> Validar em `https://learn.microsoft.com/windows/apps/publish/store-policies`

---

## Categoria 1 — Identidade do Pacote (Tecnico)

- [ ] `Package/Identity/Name` no `.dproj` = valor EXATO do Partner Center
  - Verificar em: Partner Center → Product management → Product Identity
  - Comum: `12345EmpresaLTDA.GestorERP`
- [ ] `Package/Identity/Publisher` no `.dproj` = valor EXATO do Partner Center
  - Formato: `CN=Empresa LTDA, O=Empresa LTDA, C=BR, SerialNumber=XXXXX`
- [ ] Versao no formato `Major.Minor.Build.0` (quarto componente = zero)
- [ ] Versao da nova submission e numericamente MAIOR que a atualmente publicada
- [ ] Build configurado como **Release** (nao Debug)
- [ ] Plataforma alvo: **Win64** para submissao a Store

---

## Categoria 2 — Build e Qualidade (Tecnico)

- [ ] App compilado sem erros (`dcc64 GestorERP.dpr` retornou 0 erros)
- [ ] MSIX gerado com sucesso pelo Deployment Manager ou MakeAppx
- [ ] **WACK executado e aprovado sem erros criticos**
  - `appcert.exe test "caminho\GestorERP.msix" "relatorio.xml"`
  - Ver `wack_errors_common.md` para erros frequentes
- [ ] App testado via sideload do MSIX em maquina limpa antes de submeter
  - Verificar instalacao, execucao e desinstalacao
- [ ] App nao usa APIs bloqueadas pela sandbox da Store
  - Verificar no WACK: "Windows Security Features" e "Supported APIs"
- [ ] Sem DLLs nao autorizadas bundled (WACK verifica)
- [ ] Manifesto AppxManifest.xml valido (WACK verifica)

---

## Categoria 3 — Metadados e Listagem

- [ ] Icone da Store carregado: **300×300 px PNG**
- [ ] Pelo menos **1 screenshot desktop** com dimensao minima 1366×768 px
- [ ] Descricao preenchida em **todos os idiomas suportados**
  - Minimo: pt-BR; recomendado: pt-BR + en-US
  - Limite: 10.000 caracteres por idioma
- [ ] Descricao curta preenchida (ate 270 caracteres) — afeta SEO da Store
- [ ] **Notas de versao preenchidas em todos os idiomas**
  - Obrigatorio em CADA submission, incluindo a primeira
- [ ] Categoria do app selecionada corretamente (ex.: Business → Productivity)
- [ ] Palavras-chave definidas (ate 7 por idioma) para ASO

---

## Categoria 4 — Privacidade e Compliance

- [ ] **URL de politica de privacidade** preenchida e acessivel publicamente
  - Obrigatorio se o app coleta QUALQUER dado do usuario
  - URL deve abrir sem login
- [ ] A politica de privacidade descreve corretamente os dados coletados
- [ ] App coleta apenas dados minimos necessarios (principio de minimizacao)
- [ ] Dados pessoais de menores (< 13 anos) nao sao coletados sem consentimento parental
- [ ] Se o app usa localizacao: descrito na politica de privacidade

---

## Categoria 5 — Classificacao de Conteudo (IARC)

- [ ] **Questionario IARC preenchido e aprovado**
  - Partner Center → Age ratings → Start questionnaire
  - Sem classificacao = submissao rejeitada automaticamente
- [ ] Classificacoes geradas foram revisadas e estao corretas
- [ ] Se o app contem compras in-app: marcado no questionario IARC

---

## Categoria 6 — Precificacao e Disponibilidade

- [ ] Preco definido: gratuito, pago ou trial
- [ ] Mercados selecionados (padrao: todos)
  - Restringir se necessario por compliance regional
- [ ] Data de disponibilidade configurada (imediata ou agendada)
- [ ] Staged rollout configurado (se desejado — ver `staged_rollout.md`)

---

## Categoria 7 — Compras In-App (se aplicavel)

- [ ] Produtos in-app cadastrados no Partner Center antes da submission
  - Partner Center → Seu app → In-app products → Add-on
- [ ] IDs dos produtos no codigo correspondem aos IDs no Partner Center
- [ ] Produtos testados com `CurrentAppSimulator` em modo Debug
- [ ] Fluxo de compra testado em ambiente de sandbox

---

## Categoria 8 — Politicas da Store

- [ ] App nao imita ou replica funcionalidades ja presentes no Windows
  - Exceto se adicionar valor significativo
- [ ] App nao contem conteudo adulto sem classificacao adequada
- [ ] App nao usa tecnicas de dark pattern para enganar usuarios
- [ ] App nao faz publicidade enganosa (screenshots representam o app real)
- [ ] Nomes de marcas de terceiros nao sao usados de forma enganosa

---

## Categoria 9 — Certificacao e Rollout

- [ ] Aguardar email de confirmacao da certificacao
  - Novos apps: 1-3 dias uteis
  - Updates: 1-2 dias uteis
- [ ] Se rejected: ler o relatorio de rejeicao e corrigir TODOS os pontos
- [ ] Apos aprovacao: monitorar crash rate nas primeiras 48h
- [ ] Se staged rollout: aumentar porcentagem conforme cronograma

---

## Resumo de Bloqueadores de Submissao

Os itens abaixo causam rejeicao automatica — verificar ANTES de submeter:

| Bloqueador | Consequencia |
|-----------|-------------|
| WACK com erros criticos | Submission rejeitada imediatamente |
| Sem classificacao IARC | Submission rejeitada imediatamente |
| Package Identity incorreto | MSIX invalido; submission rejeitada |
| Versao nao incrementada | Submission rejeitada |
| Sem notas de versao | Submission nao pode ser concluida |
| URL de privacidade invalida (404) | Submission rejeitada na revisao manual |
| Screenshot abaixo do tamanho minimo | Submission nao pode ser concluida |
| Icone 300×300 ausente | Submission nao pode ser concluida |
