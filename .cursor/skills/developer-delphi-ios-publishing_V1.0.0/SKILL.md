---
name: developer-delphi-ios-publishing
description: Publicação de app iOS com Delphi (App Store, Enterprise interno e MDM), cobrindo dproj, provisioning, certificados, IPA e validacoes de distribuicao.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-ios-publishing

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill governa o fluxo completo de publicação de aplicativos iOS gerados com Delphi, desde a validação do `.dproj` e certificados até a geração do `.ipa` assinado e distribuição (App Store, OTA Enterprise ou MDM). Cobre configuração de provisioning, `Info.plist`, `Entitlements.plist` e plano de renovação de certificados. Não aborda lógica de domínio, regras de negócio, compilação FPC ou design de UI — essas responsabilidades pertencem a skills dedicadas.

## When to use

- Publicar app iOS/iPadOS gerado em Delphi para App Store, distribuicao interna (Enterprise) ou MDM.
- Revisar configuracao de `.dproj`, assinatura, provisioning e fluxo de atualizacao.
- Planejar renovação de certificados ou migração de perfil de provisionamento.

## When NOT to use

- Design de domínio ou regras de negócio → usar `developer-delphi-to-fpc-architecture-and-design`.
- Compilação FPC (escopo desta skill é exclusivamente iOS com Delphi).
- Build cross-platform sem alvo iOS → usar `developer-delphi-to-fpc-build`.
- Empacotamento para plataformas desktop (Windows/macOS) → usar `developer-delphi-packaging-delivery`.
- Orquestração de múltiplas etapas Delphi → usar `developer-delphi-master-orchestrator`.

## Inputs

- Tipo de distribuicao: App Store, Enterprise interno (OTA) ou MDM.
- `Bundle Identifier`, versao (`CFBundleShortVersionString`) e build (`CFBundleVersion`).
- Certificado de distribuicao e provisioning profile.
- Configuracoes de target iOS no `.dproj`.
- Se distribuicao OTA interna: URL HTTPS do manifesto e do `.ipa`.

## Dependências (skills prévias)

| Skill                             | Quando executar antes                                           |
| --------------------------------- | --------------------------------------------------------------- |
| `developer-delphi-to-fpc-build` | Para validar que o build iOS compila sem erros antes do signing |
| `developer-delphi-build-toolchain`   | Para verificar exemplos de compile.md antes de build iOS        |
| `developer-delphi-master-orchestrator`         | Quando iOS for etapa de um fluxo multi-plataforma               |

## Workflow executavel

1. Confirmar modelo de distribuicao (App Store, Enterprise, MDM) e restricoes.
2. Validar `.dproj` para target iOS Release (assinatura, provisioning, bundle id, versao).
3. Validar arquivos acessorios: `Info.plist`, `Entitlements.plist`, icones/assets.
4. Gerar `.ipa` assinado.
5. Se OTA interna, gerar manifesto `.plist` e publicar `.ipa` + `.plist` em HTTPS.
6. Validar instalacao/atualizacao e politica de expiracao de perfil/certificado.
7. Registrar riscos, decisoes e evidencias no changelog/documentacao.

## Checklist iOS (Delphi)

- [ ] `.dproj` com target iOS Device 64-bit em Release.
- [ ] `Bundle Identifier` igual ao App ID do provisioning.
- [ ] Certificado e provisioning validos e nao expirados.
- [ ] `Info.plist` com permissoes obrigatorias (`NS*UsageDescription`) quando aplicavel.
- [ ] `Entitlements.plist` alinhado com capabilities habilitadas.
- [ ] `.ipa` assinado com sucesso.
- [ ] Para OTA interna: manifesto `.plist`, HTTPS e MIME types corretos.
- [ ] Plano de renovacao de certificado/perfil antes da expiracao.

## Checklist Delphi+FPC

- [ ] Compilação sem hints/warnings em Delphi (dcc32 + dcc64 onde aplicável)
- [ ] Memory management: Create/Free em try..finally; sem leaks (`ReportMemoryLeaksOnShutdown`)
- [ ] Tratamento de exceções: hierarquia do projeto (`EProviderError` ou equivalente)
- [ ] Nomenclatura: prefixos `T`/`I`/`E`/`F`/`A` conforme `documentation-project-expert`
- [ ] Diretivas `{$IFDEF}` conforme `developer-delphi-programming-conditional-defines`; sem mistura com paths
- [ ] Separação UI/lógica: zero SQL ou regras de negócio em event handlers
- [ ] Plano inclui validação cross-compiler (quando aplicável ao target iOS)
- [ ] Referências a `compile.md` e `diretivas_compilacao.md` verificadas quando aplicável

## Configuracao recomendada do .dproj (resumo)

- Target iOS Release ativo.
- Bundle id estavel por ambiente.
- Versionamento semanticamente controlado.
- Parametros de assinatura por configuracao (Debug/Release separados).
- Deployment manager incluindo assets e plists obrigatorios.

## Exemplo mínimo compilável

**Delphi iOS (preflight check):**

```pascal
program IOSPublishSample;
{$APPTYPE CONSOLE}
uses
  System.SysUtils;
begin
  Writeln('iOS publishing preflight check OK');
end.
```

## Avaliacao de risco e confirmacao

- Se houver risco de indisponibilizar app em producao (revogacao de certificado, expiracao de provisioning, troca de bundle id), parar e confirmar com o usuario.
- Se a publicacao envolver distribuicao interna sem MDM, confirmar impacto operacional (ex.: confianca do perfil e requisitos de dispositivo).
- Se houver qualquer acao irreversivel em certificados/perfis, pedir aprovacao explicita antes.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| ----------- | ---------------- | ------------- |
| Usar certificado de desenvolvimento para distribuição App Store | App Store rejeita builds não assinados com certificado de distribuição | Gerar `.ipa` com Distribution Certificate e provisioning de distribuição |
| Bundle Identifier diferente entre `.dproj` e provisioning profile | Falha na instalação e rejeição na App Store | Alinhar `Bundle Identifier` em `.dproj` e no App ID do portal Apple |
| Não planejar renovação de certificados | Expiração em produção causa indisponibilidade imediata do app | Criar alerta 30 dias antes do vencimento; documentar calendário de renovação |
| Subir `.ipa` OTA via HTTP | iOS bloqueia instalação OTA sem HTTPS desde iOS 7.1 | Publicar manifesto e `.ipa` exclusivamente em servidor HTTPS com certificado válido |
| `Info.plist` sem `NS*UsageDescription` para permissões usadas | App Store rejeita apps sem descrição de permissão | Adicionar todas as `NS*UsageDescription` correspondentes às APIs utilizadas |

## Métricas de sucesso

- `.ipa` gerado e instalado com sucesso no dispositivo alvo sem erros de signing.
- App Store Connect aceita o build sem rejeição por certificado, provisioning ou `Info.plist`.
- Plano de renovação de certificado documentado e registrado em calendário do projeto.
- OTA interna acessível via HTTPS e instalável sem intervenção manual no dispositivo.

## Responsável principal

| Papel              | Quem                                        |
| ------------------ | ------------------------------------------- |
| Executor           | Desenvolvedor Delphi iOS                    |
| Revisor            | `developer-delphi-testing-and-quality`            |
| Governança/release | `developer-delphi-packaging-delivery`       |

## Referencias

- `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md`
- [Apple Deployment Guide](https://support.apple.com/pt-br/guide/deployment/depce7cefc4d/web)
- Apple Developer (manifest/install commands e provisioning)

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `delphi-ios-publishing`; novo prefixo canônico `developer-delphi`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem). Referências internas atualizadas para nomes canônicos.
