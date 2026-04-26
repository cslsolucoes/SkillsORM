#!/usr/bin/env bash
# TEMPLATE: Comandos de gestao de keystore Android
#
# INSTRUCOES:
# 1. Substituir [APP_NAME] pelo nome do app (ex.: meuapp)
# 2. Substituir [COMPANY_NAME] pelo nome da empresa
# 3. Substituir [CITY], [STATE], [COUNTRY_CODE] pelos valores corretos
# 4. NUNCA versionar este arquivo com senhas preenchidas
# 5. Usar variaveis de ambiente para senhas ($KEYSTORE_PASS, $KEY_ALIAS_PASS)
#
# COMPATIBILIDADE: bash + JDK instalado (keytool no PATH)
# Para Windows: usar Git Bash, WSL ou PowerShell com keytool do JDK

set -euo pipefail

APP_NAME="[APP_NAME]"
KEYSTORE_FILE="${APP_NAME}.keystore"
ALIAS="${APP_NAME}"
COMPANY_NAME="[COMPANY_NAME]"
CITY="[CITY]"
STATE="[STATE]"
COUNTRY="[COUNTRY_CODE]"  # ex.: BR

# ==============================================================
# CRIAR NOVA KEYSTORE
# ==============================================================
create_keystore() {
  echo "Criando keystore: ${KEYSTORE_FILE}"
  echo "ATENCAO: Guarde as senhas em um gerenciador de senhas!"
  echo ""

  keytool -genkey -v \
    -keystore "${KEYSTORE_FILE}" \
    -alias "${ALIAS}" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -dname "CN=${COMPANY_NAME}, OU=Mobile, O=${COMPANY_NAME}, L=${CITY}, ST=${STATE}, C=${COUNTRY}"

  # Alternativa: fornecer senhas via parametro (nao recomendado para uso manual)
  # -storepass "${KEYSTORE_PASS}" \
  # -keypass "${KEY_ALIAS_PASS}"

  echo ""
  echo "Keystore criada: ${KEYSTORE_FILE}"
  echo "BACKUP OBRIGATORIO: copiar para local seguro imediatamente!"
}

# ==============================================================
# VERIFICAR KEYSTORE EXISTENTE
# ==============================================================
verify_keystore() {
  if [ -z "${KEYSTORE_PASS:-}" ]; then
    echo "Erro: variavel KEYSTORE_PASS nao definida"
    exit 1
  fi

  echo "Verificando keystore: ${KEYSTORE_FILE}"
  keytool -list -v \
    -keystore "${KEYSTORE_FILE}" \
    -storepass "${KEYSTORE_PASS}"
}

# ==============================================================
# EXPORTAR CERTIFICADO PEM (para Play App Signing)
# ==============================================================
export_certificate_pem() {
  if [ -z "${KEYSTORE_PASS:-}" ]; then
    echo "Erro: variavel KEYSTORE_PASS nao definida"
    exit 1
  fi

  OUTPUT_FILE="${APP_NAME}_upload_cert.pem"

  echo "Exportando certificado PEM: ${OUTPUT_FILE}"
  keytool -export -rfc \
    -keystore "${KEYSTORE_FILE}" \
    -alias "${ALIAS}" \
    -storepass "${KEYSTORE_PASS}" \
    -file "${OUTPUT_FILE}"

  echo "Certificado exportado: ${OUTPUT_FILE}"
  echo "Usar no Google Play Console > App integrity > App signing > Upload certificate"
}

# ==============================================================
# VERIFICAR ASSINATURA DE APK/AAB
# ==============================================================
verify_apk_signature() {
  local APK_FILE="${1:-${APP_NAME}.apk}"

  if [ ! -f "${APK_FILE}" ]; then
    echo "Erro: arquivo nao encontrado: ${APK_FILE}"
    exit 1
  fi

  echo "Verificando assinatura: ${APK_FILE}"

  # apksigner do Android SDK
  if command -v apksigner &>/dev/null; then
    apksigner verify --verbose "${APK_FILE}"
  else
    echo "apksigner nao encontrado. Caminho tipico:"
    echo "  Windows: %ANDROID_SDK%\\build-tools\\34.0.0\\apksigner.bat"
    echo "  Linux/Mac: \$ANDROID_SDK/build-tools/34.0.0/apksigner"
  fi
}

# ==============================================================
# GERAR APKs A PARTIR DO AAB (para testes locais)
# ==============================================================
build_apks_from_bundle() {
  local AAB_FILE="${1:-${APP_NAME}.aab}"
  local OUTPUT_APKS="${APP_NAME}.apks"

  if [ -z "${KEYSTORE_PASS:-}" ] || [ -z "${KEY_ALIAS_PASS:-}" ]; then
    echo "Erro: definir KEYSTORE_PASS e KEY_ALIAS_PASS"
    exit 1
  fi

  echo "Gerando APKs a partir do bundle: ${AAB_FILE}"

  # Requer bundletool.jar (baixar de: github.com/google/bundletool/releases)
  java -jar bundletool.jar build-apks \
    --bundle="${AAB_FILE}" \
    --output="${OUTPUT_APKS}" \
    --ks="${KEYSTORE_FILE}" \
    --ks-pass="pass:${KEYSTORE_PASS}" \
    --ks-key-alias="${ALIAS}" \
    --key-pass="pass:${KEY_ALIAS_PASS}"

  echo "APKs gerados: ${OUTPUT_APKS}"
  echo "Para instalar no dispositivo conectado:"
  echo "  java -jar bundletool.jar install-apks --apks=${OUTPUT_APKS}"
}

# ==============================================================
# MENU DE USO
# ==============================================================
show_usage() {
  echo "Uso: $0 [comando]"
  echo ""
  echo "Comandos:"
  echo "  create    - Criar nova keystore"
  echo "  verify    - Verificar keystore existente"
  echo "  export    - Exportar certificado PEM"
  echo "  sign      - Verificar assinatura de APK/AAB"
  echo "  apks      - Gerar APKs a partir de AAB (requer bundletool)"
  echo ""
  echo "Variaveis de ambiente necessarias (exceto 'create'):"
  echo "  KEYSTORE_PASS  - Senha da keystore"
  echo "  KEY_ALIAS_PASS - Senha do alias"
  echo ""
  echo "Exemplos:"
  echo "  $0 create"
  echo "  KEYSTORE_PASS=senha $0 verify"
  echo "  $0 sign MeuApp.aab"
}

# ==============================================================
# PONTO DE ENTRADA
# ==============================================================
case "${1:-usage}" in
  create)  create_keystore ;;
  verify)  verify_keystore ;;
  export)  export_certificate_pem ;;
  sign)    verify_apk_signature "${2:-}" ;;
  apks)    build_apks_from_bundle "${2:-}" ;;
  *)       show_usage ;;
esac
