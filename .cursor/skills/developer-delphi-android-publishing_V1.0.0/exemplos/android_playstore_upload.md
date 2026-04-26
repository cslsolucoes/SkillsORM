# Guia: Google Play Console — Upload e Publicação

## Criar Conta no Google Play Console

1. Acessar `play.google.com/console`
2. Fazer login com conta Google
3. Aceitar os termos de desenvolvedor
4. Pagar taxa única de **USD 25** (cartao de credito)
5. Preencher perfil do desenvolvedor (nome, email de contato, website)

## Criar Novo App

1. **All apps > Create app**
2. Preencher:
   - **App name**: nome que aparece na Play Store
   - **Default language**: idioma principal
   - **App or Game**: tipo do conteúdo
   - **Free or paid**: modelo de monetização
3. Aceitar as políticas
4. Clicar **Create app**

## Configurar Store Presence (obrigatório antes do primeiro submit)

### Store Listing

**Grow > Store presence > Main store listing:**

| Campo | Obrigatório | Limite |
|-------|-------------|--------|
| App name | Sim | 50 chars |
| Short description | Sim | 80 chars |
| Full description | Sim | 4000 chars |
| App icon | Sim | 512x512 PNG |
| Feature graphic | Sim | 1024x500 PNG |
| Phone screenshots | Sim (min. 2) | Max. 8 |

### App Content (obrigatório)

**Policy > App content:**

1. **Privacy policy**: URL da política de privacidade (obrigatório)
2. **Ads**: declarar se o app exibe anúncios
3. **Content rating**: preencher questionário IARC
4. **Target audience**: faixa etária
5. **Data safety**: declarar quais dados são coletados/compartilhados

## Fluxo de Publicação — Internal → Production

### Estratégia recomendada

```
Internal testing (sem revisão, publicação imediata)
       ↓ (validar build, testes da equipe)
Closed testing / Alpha (grupo fechado de testadores)
       ↓ (feedback, correções)
Open testing / Beta (testadores externos)
       ↓ (estabilização)
Production (rollout gradual: 10% → 50% → 100%)
```

### Internal Testing (primeiro teste)

1. **Release > Internal testing > Create new release**
2. **Upload** → selecionar `.aab`
3. Aguardar processamento do bundle
4. Preencher release notes
5. Clicar **Save** → **Review release** → **Start rollout to Internal testing**
6. Disponível imediatamente para testadores internos (sem revisão do Google)
7. Adicionar testadores: **Testers** → criar lista → adicionar emails

### Closed Testing (Alpha)

1. **Release > Closed testing (Alpha) > Create new release**
2. Upload mesmo AAB ou novo AAB
3. Criar grupo de testadores (por email ou link de opt-in)
4. Submit → revisão pode ser necessária

### Production (publicação pública)

1. **Release > Production > Create new release**
2. Upload AAB de produção (assinado com keystore de produção)
3. Preencher "What's new" por idioma
4. Clicar **Review release**
5. Verificar avisos e erros (corrigir se necessário)
6. Clicar **Start rollout to Production**
7. Definir percentual de rollout:
   - **100%**: disponível a todos imediatamente
   - **Staged**: ex.: 10% → aumentar gradualmente → 100%

### Tempo de Revisão

| Tipo | Tempo estimado |
|------|----------------|
| Novo app (primeiro submit) | 1-7 dias úteis |
| Atualização | Horas a 2-3 dias úteis |
| Internal testing | Imediato (sem revisão) |

## Play App Signing — Configuração Inicial

**Fazer antes do primeiro upload de produção:**

1. **Release > Setup > App integrity > App signing**
2. Clicar **Opt in** (aceitar os termos)
3. O Google gera e gerencia a **app signing key**
4. Sua keystore se torna a **upload key** (usada apenas para autenticar uploads)
5. Opcional: exportar certificado PEM da sua keystore para o Google:
   ```bash
   keytool -export -rfc -keystore meuapp.keystore -alias meuapp -file upload_cert.pem
   ```

## Rollout Gradual — Gerenciar

Para aumentar o percentual de rollout:

1. **Production > [release atual]**
2. Clicar **Manage rollout**
3. Aumentar para o próximo percentual
4. Monitorar **Android Vitals** para crashes e ANRs antes de aumentar

Para pausar rollout (se detectar problema crítico):

1. **Manage rollout > Halt rollout**
2. Corrigir o problema → publicar nova versão

## Troubleshooting Comum

| Erro | Causa | Solução |
|------|-------|---------|
| "Version code already used" | `versionCode` repetido | Incrementar `Android_VersionCode` |
| "APK not signed" | Build sem assinatura | Verificar configuração de keystore no `.dproj` |
| "Target API too low" | `targetSdkVersion` abaixo do exigido | Atualizar para API 34+ |
| "Missing privacy policy" | URL não informada | Adicionar URL em App content |
| "Data safety incomplete" | Formulário não preenchido | Completar Data safety section |
| "Release rejected" | Violação de política | Ler email de rejeição e corrigir |

## Monitoramento Pós-Publicação

**Android Vitals (Monitoring):**
- **Crash rate**: manter abaixo de 1.09% (threshold do Google)
- **ANR rate**: manter abaixo de 0.47%
- Receber alertas quando ultrapassar os thresholds

**Play Store ratings:**
- Responder reviews negativos rapidamente
- Usar feedback para priorizar correções
