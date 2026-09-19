#!/usr/bin/env bash
# Regenerates lib/proto/ from ../proto/emergency_message.proto.
# Only needed when the .proto file changes; the generated files are committed.
#
# Needs:
#   - protoc: set $PROTOC, or build the backend once (Gradle caches protoc.exe)
#   - protoc-gen-dart: dart pub global activate protoc_plugin 25.1.0
set -euo pipefail
cd "$(dirname "$0")/.."

PROTOC="${PROTOC:-$(find ~/.gradle/caches -name 'protoc-4.36.2-*.exe' 2>/dev/null | head -1)}"
PLUGIN="${LOCALAPPDATA:-$HOME/.pub-cache}/Pub/Cache/bin/protoc-gen-dart.bat"
[ -f "$PLUGIN" ] || PLUGIN="$HOME/.pub-cache/bin/protoc-gen-dart"

mkdir -p lib/proto
"$PROTOC" --plugin=protoc-gen-dart="$PLUGIN" \
  --dart_out=lib/proto -I ../proto ../proto/emergency_message.proto
echo "Generated: $(ls lib/proto)"
