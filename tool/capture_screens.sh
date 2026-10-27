#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
device="${1:-emulator-5554}"
for first in 1 21 41; do
  last=$((first + 19))
  flutter drive --driver=test_driver/integration_test.dart \
    --target=integration_test/app_test.dart -d "$device" \
    --dart-define=CAPTURE_FROM="$first" --dart-define=CAPTURE_TO="$last"
done
