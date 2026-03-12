#!/usr/bin/env bash
set -euo pipefail

OUT_FILE="${1:-fdroid-repo.jks}"
ALIAS="${FDROID_KEY_ALIAS:-fdroidrepo}"
STORE_PASS="${FDROID_KEYSTORE_PASSWORD:-}"
KEY_PASS="${FDROID_KEY_PASSWORD:-}"

if [[ -z "$STORE_PASS" || -z "$KEY_PASS" ]]; then
  echo "Set FDROID_KEYSTORE_PASSWORD and FDROID_KEY_PASSWORD before running."
  exit 1
fi

keytool -genkeypair \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 4096 \
  -validity 36500 \
  -keystore "$OUT_FILE" \
  -storepass "$STORE_PASS" \
  -keypass "$KEY_PASS" \
  -dname "CN=khonager F-Droid Repo, OU=Apps, O=khonager, L=Internet, S=Internet, C=US"

base64 -w0 "$OUT_FILE" > "${OUT_FILE}.base64"
echo "Created: $OUT_FILE"
echo "Base64 secret file: ${OUT_FILE}.base64"
