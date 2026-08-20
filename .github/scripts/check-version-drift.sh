#!/bin/bash
# Verify OptimizelySwiftSDK version is the same in both podspec and Package.swift.
# Exits non-zero if versions diverge (FR-014).

set -euo pipefail

PODSPEC="ios/optimizely_flutter_sdk.podspec"
PACKAGE_SWIFT="ios/optimizely-flutter-sdk/Package.swift"

PODSPEC_VER=$(grep "OptimizelySwiftSDK" "$PODSPEC" | grep -oE "'[0-9]+\.[0-9]+\.[0-9]+'" | tr -d "'")
SPM_VER=$(grep 'exact' "$PACKAGE_SWIFT" | grep -oE '"[0-9]+\.[0-9]+\.[0-9]+"' | tr -d '"')

if [ -z "$PODSPEC_VER" ] || [ -z "$SPM_VER" ]; then
  echo "FAIL: Could not extract version from one or both files"
  echo "  podspec: ${PODSPEC_VER:-<not found>}"
  echo "  Package.swift: ${SPM_VER:-<not found>}"
  exit 1
fi

if [ "$PODSPEC_VER" != "$SPM_VER" ]; then
  echo "FAIL: OptimizelySwiftSDK version mismatch"
  echo "  podspec: $PODSPEC_VER"
  echo "  Package.swift: $SPM_VER"
  exit 1
fi

echo "OK: OptimizelySwiftSDK version matches ($PODSPEC_VER)"
