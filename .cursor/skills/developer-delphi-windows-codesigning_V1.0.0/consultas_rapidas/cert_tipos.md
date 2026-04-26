# Tipos de Certificado de Code Signing — Referencia Rapida

## Tabela comparativa completa

| Tipo | Custo anual | Validade tipica | SmartScreen | Ferramenta | Quando usar |
|------|-------------|-----------------|-------------|------------|-------------|
| Auto-assinado | Gratis | 1 ano (configuravel) | Bloqueado | PowerShell `New-SelfSignedCertificate` | Testes locais, sideload interno controlado |
| OV Code Signing (Organization Validated) | USD 200-350 | 1-3 anos | Aviso inicial (some com reputacao) | signtool.exe | Distribuicao publica fora da Store |
| EV Code Signing (Extended Validation) | USD 400-500 | 1-3 anos | Sem aviso imediatamente | signtool.exe + token HSM | Drivers, software critico, remover aviso imediato |
| Microsoft Store (Publisher Certificate) | Incluso (conta $19) | Gerenciado pela MS | Sem aviso | Partner Center | Distribuicao via Microsoft Store |

---

## Detalhe por tipo

### Auto-assinado

- Criado localmente com `New-SelfSignedCertificate` (PowerShell 5.1+)
- Confiavel SOMENTE em maquinas onde o `.cer` foi instalado manualmente no Trusted Root
- SmartScreen bloqueia por padrao em outras maquinas
- Uso: ambiente de desenvolvimento, pipeline CI interno, testes de sideload em maquinas controladas
- NUNCA usar para distribuicao publica

### OV Code Signing

- Emitido por CA publica (DigiCert, Sectigo, GlobalSign, Comodo)
- Valida a identidade da organizacao (documentos legais exigidos)
- SmartScreen mostra aviso nas primeiras execucoes; some conforme reputacao e construida
- Chave privada pode ser armazenada em arquivo PFX (risco se PFX for comprometido)
- Processo de emissao: 1-5 dias uteis

### EV Code Signing

- Validacao estendida: auditoria fisica da empresa
- Token HSM fisico obrigatorio (ex.: SafeNet, YubiKey com suporte a EV)
- SmartScreen: zero aviso imediatamente apos emissao
- Obrigatorio para assinar drivers no modo kernel (WHQL)
- Processo de emissao: 3-14 dias uteis
- A chave privada NUNCA deixa o token HSM

### Microsoft Store

- O desenvolvedor NAO assina o MSIX antes de submeter
- A Microsoft assina apos aprovacao no Partner Center
- O MSIX gerado pelo RAD Studio deve ser enviado sem assinatura para submissao na Store
- Para sideload de testes, assinar com certificado proprio (auto-assinado ou OV/EV)

---

## Provedores recomendados

| Provedor | Tipo disponivel | URL |
|---------|----------------|-----|
| DigiCert | OV, EV | digicert.com |
| Sectigo (ex-Comodo) | OV, EV | sectigo.com |
| GlobalSign | OV, EV | globalsign.com |
| Entrust | OV, EV | entrust.com |
| SSL.com | OV, EV | ssl.com |

---

## Fluxo de decisao

```
Preciso distribuir para a Microsoft Store?
  SIM → Nao assinar; submeter via Partner Center
  NAO → E para testes/desenvolvimento?
    SIM → Usar certificado auto-assinado
    NAO → E driver ou software critico sem tolerancia a aviso SmartScreen?
      SIM → EV Code Signing + token HSM
      NAO → OV Code Signing (mais barato, SmartScreen some com tempo)
```
