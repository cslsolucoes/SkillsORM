# Checklist Completo: Submissão Android Play Store

## Pre-Build

- [ ] `Android_VersionCode` incrementado (verificar que é maior que o anterior em produção)
- [ ] `Android_VersionName` atualizado (ex.: de `1.0.0` para `1.1.0`)
- [ ] `Android_TargetSdkVersion` >= 34 (exigência Google Play 2024+)
- [ ] `Android_MinSdkVersion` >= 26 (mínimo prático para Delphi FMX)
- [ ] Keystore de produção configurada no `.dproj` (não debug keystore)
- [ ] Variáveis de ambiente `KEYSTORE_PASS` e `KEY_ALIAS_PASS` definidas
- [ ] `Android_GenerateBundle` = `true` no Release

## Build e Geração do AAB

- [ ] Platform = `Android 64-bit`, Configuration = `Release`
- [ ] Build realizado sem erros ou warnings críticos
- [ ] Arquivo `.aab` gerado em `.\Android\Release\<App>\bin\`
- [ ] Assinatura verificada com `apksigner verify --verbose <app>.aab`
- [ ] Testado em dispositivo físico com o AAB gerado (via bundletool)

## Teste Antes do Submit

- [ ] Testado em dispositivo Android físico (não apenas emulador)
- [ ] Testado em pelo menos 2 versões diferentes de Android (ex.: API 26 e API 34)
- [ ] Testado em smartphone E tablet (se app é Universal)
- [ ] Fluxo crítico testado de ponta a ponta (login, funcionalidade principal, etc.)
- [ ] Permissões testadas: solicitar, negar, solicitar novamente
- [ ] App não crasha no primeiro uso
- [ ] Comportamento correto em rotação de tela

## Store Listing (Play Console)

- [ ] Título do app (máx. 50 caracteres)
- [ ] Descrição curta (máx. 80 caracteres)
- [ ] Descrição completa (máx. 4000 caracteres, sem HTML)
- [ ] Ícone 512x512 PNG (sem transparência, sem bordas arredondadas — Google aplica)
- [ ] Feature Graphic 1024x500 PNG
- [ ] Screenshots smartphone: mínimo 2, máximo 8 por idioma
- [ ] Screenshots tablet 7" (recomendado)
- [ ] Screenshots tablet 10" (recomendado)
- [ ] Categorias corretas selecionadas

## App Content (Política — obrigatório)

- [ ] Política de privacidade: URL válida e acessível publicamente
- [ ] Classificação de conteúdo IARC preenchida (questionário completo)
- [ ] Seção "Data safety" preenchida:
  - [ ] Dados coletados declarados
  - [ ] Dados compartilhados com terceiros declarados
  - [ ] Práticas de segurança informadas
- [ ] Target audience definido (faixa etária)
- [ ] Declaração sobre anúncios (se o app exibe)

## Técnico — Boas Práticas

- [ ] Permissões no manifesto = somente as realmente usadas no código
- [ ] Nenhuma permissão sensível desnecessária declarada
- [ ] `android:extractNativeLibs="true"` no manifesto (necessário para Delphi)
- [ ] `android:exported` definido em todas as Activities/Services/Receivers (API 31+)
- [ ] Sem credenciais hardcoded no código (senhas, API keys)
- [ ] Certificado de produção usado (não o debug.keystore gerado automaticamente)

## Upload e Publicação

- [ ] Upload do AAB bem-sucedido (sem erros no Play Console)
- [ ] Release notes preenchidas em todos os idiomas suportados
- [ ] Revisão do release feita (botão "Review release")
- [ ] Nenhum erro crítico ou aviso bloqueante
- [ ] Rollout configurado (100% ou percentual inicial para staged rollout)

## Pós-Publicação

- [ ] App disponível na Play Store (aguardar revisão: 1-3 dias úteis para novos apps)
- [ ] Download e instalação testados após publicação
- [ ] Monitorar Android Vitals nas primeiras 48h:
  - [ ] Crash rate < 1.09%
  - [ ] ANR rate < 0.47%
- [ ] Versão do `.dproj` commitada no repositório git com tag de versão

## Keystore — Checklist de Segurança

- [ ] Keystore armazenada em local seguro (fora do repositório git)
- [ ] Backup offline da keystore realizado
- [ ] Senhas em gerenciador de senhas
- [ ] `.gitignore` inclui `*.keystore` e `*.jks`
- [ ] Play App Signing configurado (recomendado fortemente)
