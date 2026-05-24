#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

python3 tool/gen_dart_defines.py --env-file .env --out .dart-defines.json >/dev/null

if command -v fvm >/dev/null 2>&1; then
  exec fvm flutter build appbundle --release --dart-define-from-file=.dart-defines.json "$@"
fi

exec flutter build appbundle --release --dart-define-from-file=.dart-defines.json "$@"

