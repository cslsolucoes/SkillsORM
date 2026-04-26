# Guia: Certificados Apple para iOS

## Tipos de Certificado

| Certificado | Uso | Quem pode criar |
|-------------|-----|-----------------|
| Apple Development | Testes em dispositivo físico | Qualquer membro da equipe |
| Apple Distribution | Ad Hoc e App Store | Somente Account Holder ou Admin |

## Pré-requisito: Programa Apple Developer

- Conta gratuita: apenas certificados Development, sem publicação na App Store
- Conta paga (USD 99/ano): todos os tipos + publicação na App Store
- Conta Enterprise (USD 299/ano): distribuição interna sem App Store

## Criar Certificado via Xcode (Recomendado)

### Passo a passo

1. Abrir **Xcode** no Mac
2. **Xcode > Settings** (⌘,) → aba **Accounts**
3. Clicar **+** (adicionar Apple ID) se ainda não adicionado
4. Selecionar o Apple ID → clicar **Manage Certificates...**
5. Clicar **+** no canto inferior esquerdo
6. Selecionar **Apple Development** (ou **Apple Distribution**)
7. Xcode cria o certificado e instala automaticamente no Keychain

### Verificar no Keychain Access

1. Abrir **Keychain Access** (Applications > Utilities)
2. Categoria: **My Certificates**
3. Deve aparecer: `Apple Development: Seu Nome (DEVID)`
4. Expandir → deve ter uma chave privada associada

## Criar Certificado via Apple Developer Portal (alternativa)

1. Acessar `developer.apple.com > Certificates, IDs & Profiles > Certificates`
2. Clicar **+**
3. Selecionar tipo e clicar **Continue**
4. Criar CSR (Certificate Signing Request) no Mac:
   - Abrir **Keychain Access > Certificate Assistant > Request a Certificate From a Certificate Authority**
   - Preencher email e nome; selecionar "Saved to disk"
5. Fazer upload do arquivo `.certSigningRequest`
6. Baixar o certificado `.cer`
7. Dar duplo clique no `.cer` para instalar no Keychain

## Exportar Certificado (.p12) para importar no RAD Studio

### No Mac — Keychain Access

1. Abrir **Keychain Access**
2. Categoria: **My Certificates**
3. Localizar o certificado (ex.: `Apple Development: Joao Silva (ABC123)`)
4. Botão direito → **Export "Apple Development: ..."**
5. Formato: **Personal Information Exchange (.p12)**
6. Definir senha forte para o `.p12` (guardar em local seguro)
7. Salvar o arquivo

### Importar no RAD Studio

1. **Project > Options > Provisioning** (com plataforma iOS ativa)
2. Seção **Signing Identity** → clicar **Import**
3. Selecionar o arquivo `.p12`
4. Informar a senha definida na exportação
5. O certificado aparece na lista

## Renovação de Certificados

- Certificados Apple Development: validade de **1 ano**
- Certificados Apple Distribution: validade de **1 ano**
- Renovar antes do vencimento para evitar interrupção de builds
- Xcode avisa quando o certificado está próximo do vencimento

## Troubleshooting

| Problema | Solução |
|----------|---------|
| "No valid certificate" | Certificado expirado ou não importado no RAD Studio |
| "Certificate not trusted" | Instalar certificado raiz Apple via Xcode |
| "Provisioning profile doesn't include certificate" | Recriar provisioning profile incluindo o certificado atual |
| Chave privada ausente | Certificado foi importado sem a chave — exportar `.p12` de volta do Mac de origem |

## Boas Práticas

- Manter máximo de **3 certificados Development** ativos (limite do Apple Developer Program)
- Revogar certificados antigos/inutilizados no portal
- Armazenar o `.p12` em local seguro (nunca no repositório git)
- Documentar qual desenvolvedor usa qual certificado
