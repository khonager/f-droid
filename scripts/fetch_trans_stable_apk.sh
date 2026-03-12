#!/usr/bin/env bash
set -euo pipefail

OWNER="${TRANS_OWNER:-khonager}"
REPO="${TRANS_REPO:-Trans}"
ASSET_NAME="${TRANS_STABLE_ASSET_NAME:-trans.apk}"
OUT_DIR="${1:-metadata/apks}"

mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/*.apk

API_URL="https://api.github.com/repos/${OWNER}/${REPO}/releases/latest"
AUTH_HEADER=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  AUTH_HEADER=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

JSON="$(curl -fsSL "${AUTH_HEADER[@]}" -H 'Accept: application/vnd.github+json' "$API_URL")"

readarray -t parsed < <(python3 - <<'PY'
import json, os, sys
j = json.loads(sys.stdin.read())
asset_name = os.environ.get("TRANS_STABLE_ASSET_NAME", "trans.apk")
tag = j.get("tag_name", "latest")
url = None
for a in j.get("assets", []):
    if a.get("name") == asset_name:
        url = a.get("browser_download_url")
        break
if not url:
    print("ERROR")
    sys.exit(1)
print(tag)
print(url)
PY
<<<"$JSON")

if [[ "${parsed[0]:-}" == "ERROR" || ${#parsed[@]} -lt 2 ]]; then
  echo "Could not find asset '$ASSET_NAME' in latest release of ${OWNER}/${REPO}" >&2
  exit 1
fi

TAG="${parsed[0]}"
URL="${parsed[1]}"
SAFE_TAG="${TAG//\//-}"
OUT_FILE="${OUT_DIR}/de.khonager.trans_${SAFE_TAG}.apk"

curl -fL "${AUTH_HEADER[@]}" -H 'Accept: application/octet-stream' -o "$OUT_FILE" "$URL"

echo "Downloaded: $OUT_FILE"
