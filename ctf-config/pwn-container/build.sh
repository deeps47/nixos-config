#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

IMAGE="local/pwn"

echo "🔨 Building pwn container image: ${IMAGE}"

podman build \
  --tag "${IMAGE}" \
  --file "${SCRIPT_DIR}/Containerfile" \
  "${SCRIPT_DIR}"

echo ""
echo "✅ Build complete: ${IMAGE}"
