#!/usr/bin/env bash
set -euo pipefail

OWNER="${TRANS_OWNER:-khonager}"
REPO="${TRANS_REPO:-Trans}"
ASSET_NAME="${TRANS_DEV_ASSET_NAME:-trans-dev.apk}"
OUT_DIR="${1:-metadata/apks}"

mkdir -p "$OUT_DIR"

API_URL="https://api.github.com/repos/${OWNER}/${REPO}/releases?per_page=30"
AUTH_HEADER=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  AUTH_HEADER=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_JSON"' EXIT
curl -fsSL "${AUTH_HEADER[@]}" -H 'Accept: application/vnd.github+json' "$API_URL" > "$TMP_JSON"

readarray -t parsed < <(python3 - "$TMP_JSON" "$ASSET_NAME" <<'PY'
import json
import sys

if len(sys.argv) < 3:
    print("ERROR:bad-args")
    sys.exit(1)

json_path = sys.argv[1]
asset_name = sys.argv[2]

try:
    with open(json_path, "r", encoding="utf-8") as f:
        raw = f.read()
except OSError:
    print("ERROR:read-failed")
    sys.exit(1)

if not raw.strip():
    print("ERROR:empty-response")
    sys.exit(1)

try:
    releases = json.loads(raw)
except json.JSONDecodeError:
    print("ERROR:invalid-json")
    sys.exit(1)

if not isinstance(releases, list):
    print("ERROR:unexpected-payload")
    sys.exit(1)

for rel in releases:
    if rel.get("draft"):
        continue
    if not rel.get("prerelease"):
        continue

    for asset in rel.get("assets", []):
        if asset.get("name") == asset_name:
            tag = rel.get("tag_name", "latest")
            url = asset.get("browser_download_url", "")
            if not url:
                continue
            print(tag)
            print(url)
            sys.exit(0)

print("ERROR:no-matching-prerelease")
sys.exit(1)
PY
)

if [[ ${#parsed[@]} -lt 2 || "${parsed[0]}" == ERROR:* ]]; then
  echo "Could not find asset '$ASSET_NAME' in a prerelease of ${OWNER}/${REPO}" >&2
  if [[ ${#parsed[@]} -gt 0 ]]; then
    echo "Reason: ${parsed[0]}" >&2
  fi
  exit 1
fi

TAG="${parsed[0]}"
URL="${parsed[1]}"
SAFE_TAG="${TAG//\//-}"
OUT_FILE="${OUT_DIR}/de.khonager.trans.unstable_${SAFE_TAG}.apk"

rm -f "${OUT_DIR}/de.khonager.trans.unstable_"*.apk
curl -fL "${AUTH_HEADER[@]}" -H 'Accept: application/octet-stream' -o "$OUT_FILE" "$URL"

echo "Downloaded: $OUT_FILE"
