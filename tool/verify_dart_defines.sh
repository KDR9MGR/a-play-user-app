#!/usr/bin/env bash
# Run this right before Xcode Archive to confirm Generated.xcconfig actually
# has the values you expect baked in - Xcode Archive alone won't tell you
# if they're stale.
set -euo pipefail
cd "$(dirname "$0")/.."

XCCONFIG="ios/Flutter/Generated.xcconfig"
if [ ! -f "$XCCONFIG" ]; then
  echo "✗ $XCCONFIG not found - run flutter build/run at least once first."
  exit 1
fi

DEFINES_LINE=$(grep "^DART_DEFINES=" "$XCCONFIG" || true)
if [ -z "$DEFINES_LINE" ]; then
  echo "✗ No DART_DEFINES found in $XCCONFIG"
  exit 1
fi

echo "Current dart-defines baked into Generated.xcconfig:"
echo "${DEFINES_LINE#DART_DEFINES=}" | tr ',' '\n' | while read -r b64; do
  echo "  $(echo "$b64" | base64 -d)"
done
