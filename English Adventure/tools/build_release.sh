#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-windows}"
GODOT_BIN="${GODOT_BIN:-godot}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

VERSION="$(python3 -c 'import json; print(json.load(open("data/release/version.json"))["version"])')"
echo "=== English Adventure Release Builder v${VERSION} (target=${TARGET}) ==="

for s in \
  tests/content_validation/validate_prompt_02.py \
  tests/content_validation/validate_prompt_03.py \
  tests/content_validation/validate_prompt_04.py \
  tests/content_validation/validate_prompt_05.py \
  tests/content_validation/validate_prompt_06.py \
  tests/content_validation/validate_prompt_07.py \
  tests/content_validation/validate_prompt_08.py \
  tests/content_validation/validate_prompt_09.py \
  tests/content_validation/validate_prompt_10.py \
  tests/content_validation/validate_3d_visual_direction.py \
  tests/integration/run_p9_content_tests.py; do
  python3 "$s"
done

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
  echo "ERROR: Godot 4.3 CLI ('$GODOT_BIN') not found in PATH." >&2
  exit 1
fi

"$GODOT_BIN" --headless --import

export_preset() {
  local preset="$1"
  local out_path="$2"
  mkdir -p "$(dirname "$out_path")"
  "$GODOT_BIN" --headless --verbose --export-release "$preset" "$out_path"
  if [ ! -s "$out_path" ]; then
    echo "ERROR: Expected non-empty output at $out_path" >&2
    exit 1
  fi
  ls -lh "$out_path"
}

case "$TARGET" in
  windows)
    export_preset "Windows Desktop" "builds/windows/EnglishAdventure.exe"
    (cd builds/windows && zip -r "../EnglishAdventure-v${VERSION}-windows-x64.zip" .)
    ;;
  android_apk)
    export_preset "Android" "builds/android/EnglishAdventure.apk"
    ;;
  android_aab)
    export_preset "Android AAB" "builds/android/EnglishAdventure.aab"
    ;;
  ios)
    if [[ "$(uname -s)" != "Darwin" ]]; then
      echo "ERROR: iOS Xcode export requires macOS + Xcode." >&2
      exit 1
    fi
    export_preset "iOS" "builds/ios/EnglishAdventure.ipa"
    ;;
  web)
    export_preset "Web" "builds/web/index.html"
    ;;
  *)
    echo "Usage: $0 [windows|android_apk|android_aab|ios|web]" >&2
    exit 2
    ;;
esac
