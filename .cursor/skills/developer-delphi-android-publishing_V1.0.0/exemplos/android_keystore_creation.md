# Guia: Criação e Gestão de Keystore Android

## O que é uma Keystore

Uma keystore é um arquivo criptografado que contém um ou mais pares de chaves criptográficas (certificados). No Android, a keystore é usada para **assinar digitalmente** o app antes de publicar.

> CRITICO: A keystore vinculada ao app no Google Play NUNCA pode ser substituida.
> Se perdida, nao sera possivel publicar atualizacoes do mesmo app.

## Criar Keystore com keytool

O `keytool` faz parte do JDK e esta disponível em `%JAVA_HOME%\bin\keytool.exe`.

### Comando completo

```bash
keytool -genkey -v \
  -keystore meuapp.keystore \
  -alias meuapp \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

### Parametros explicados

| Parametro | Descrição | Valor recomendado |
|-----------|-----------|-------------------|
| `-keystore` | Nome/caminho do arquivo | `meuapp.keystore` |
| `-alias` | Apelido da chave dentro do arquivo | `meuapp` (nome do app) |
| `-keyalg` | Algoritmo da chave | `RSA` |
| `-keysize` | Tamanho da chave em bits | `2048` (minimo) |
| `-validity` | Validade em dias | `10000` (~27 anos) |

### Sessao interativa esperada

```
Enter keystore password: [SENHA_KEYSTORE — nunca esqueca]
Re-enter new password: [confirmar]
What is your first and last name?
  [Unknown]: Joao Silva
What is the name of your organizational unit?
  [Unknown]: Mobile
What is the name of your organization?
  [Unknown]: Minha Empresa LTDA
What is the name of your City or Locality?
  [Unknown]: Sao Paulo
What is the name of your State or Province?
  [Unknown]: SP
What is the two-letter country code for this unit?
  [Unknown]: BR
Is CN=Joao Silva, OU=Mobile, O=Minha Empresa LTDA, L=Sao Paulo, ST=SP, C=BR correct?
  [no]: yes

Generating 2,048 bit RSA key pair and self-signed certificate...
[Storing meuapp.keystore]

Enter key password for <meuapp>
	(RETURN if same as keystore password): [Enter para usar a mesma]
```

## Verificar Keystore Criada

```bash
keytool -list -v -keystore meuapp.keystore
```

Saida esperada:
```
Keystore type: PKCS12
Keystore provider: SUN

Your keystore contains 1 entry

Alias name: meuapp
Creation date: 11/04/2026
Entry type: PrivateKeyEntry
Certificate chain length: 1
Certificate[1]:
Owner: CN=Joao Silva, OU=Mobile, ...
Valid from: Sat Apr 11 00:00:00 BRT 2026 until: ...
```

## Onde Guardar a Keystore

### Estrutura recomendada no projeto

```
MeuProjeto/
  certificates/
    meuapp.keystore       ← NUNCA versionar no git
    keystore_info.txt     ← metadata (alias, validade) SEM senhas
  .gitignore              ← deve incluir certificates/*.keystore
```

### .gitignore obrigatório

```gitignore
# Keystore — NUNCA versionar
*.keystore
*.jks
certificates/
```

### Backup obrigatório

1. Copia local segura (pasta criptografada com VeraCrypt/BitLocker)
2. Copia offline (HD externo, pendrive criptografado)
3. Senhas em gerenciador (Bitwarden, 1Password, KeePass)
4. NUNCA armazenar senha junto com o arquivo da keystore

## Extrair Certificado para Play App Signing

Ao configurar Play App Signing, Google pode solicitar o certificado PEM:

```bash
keytool -export -rfc \
  -keystore meuapp.keystore \
  -alias meuapp \
  -file meuapp_certificate.pem
```

## Configurar Variáveis de Ambiente para Build

**No Windows (sessao atual):**
```cmd
set KEYSTORE_PASS=SuaSenhaKeystore
set KEY_ALIAS_PASS=SuaSenhaAlias
```

**No Windows (permanente — Control Panel > System > Advanced > Environment Variables):**
- Adicionar `KEYSTORE_PASS` e `KEY_ALIAS_PASS` como variáveis de usuario

**Em CI/CD (GitHub Actions):**
```yaml
# No repositório: Settings > Secrets and variables > Actions > New secret
# KEYSTORE_PASS e KEY_ALIAS_PASS como secrets

jobs:
  build:
    steps:
      - name: Build Release
        env:
          KEYSTORE_PASS: ${{ secrets.KEYSTORE_PASS }}
          KEY_ALIAS_PASS: ${{ secrets.KEY_ALIAS_PASS }}
        run: |
          # Comando de build aqui
```

## Emergência: Keystore Perdida

Se usar **Play App Signing** (recomendado):
1. Acessar Play Console → Release → Setup → App integrity → App signing
2. Solicitar **Request upload key reset**
3. Google mantém a app signing key; apenas o upload key muda

Se **não** usar Play App Signing:
- Não há recuperação possível
- O app deve ser publicado com novo Package Name (novo app no Play Store)
- Todos os usuários devem reinstalar o novo app

> Esta é a principal razão para sempre usar Play App Signing.
