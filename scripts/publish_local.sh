#!/usr/bin/env bash
set -euo pipefail

if ! command -v fdroid >/dev/null 2>&1; then
  echo "fdroid command not found. Install fdroidserver first."
  exit 1
fi

: "${FDROID_REPO_URL:?Set FDROID_REPO_URL}"
: "${FDROID_KEYSTORE_PASSWORD:?Set FDROID_KEYSTORE_PASSWORD}"
: "${FDROID_KEY_ALIAS:?Set FDROID_KEY_ALIAS}"
: "${FDROID_KEY_PASSWORD:?Set FDROID_KEY_PASSWORD}"
: "${FDROID_KEYSTORE_PATH:?Set FDROID_KEYSTORE_PATH}"

TMP_CONFIG="/tmp/fdroid-config.yml"
cp fdroid-config.template.yml "$TMP_CONFIG"
sed -i "s|\${FDROID_REPO_URL}|${FDROID_REPO_URL}|g" "$TMP_CONFIG"
sed -i "s|\${FDROID_KEYSTORE_PASSWORD}|${FDROID_KEYSTORE_PASSWORD}|g" "$TMP_CONFIG"
sed -i "s|\${FDROID_KEY_ALIAS}|${FDROID_KEY_ALIAS}|g" "$TMP_CONFIG"
sed -i "s|\${FDROID_KEY_PASSWORD}|${FDROID_KEY_PASSWORD}|g" "$TMP_CONFIG"

cp "$FDROID_KEYSTORE_PATH" /tmp/fdroid-keystore.jks

mkdir -p repo
cp -f metadata/apks/*.apk repo/ 2>/dev/null || true

fdroid update --config "$TMP_CONFIG" --verbose

echo "Done. Commit and push repo/ for static hosting."
