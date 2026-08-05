#!/usr/bin/env bash

set -euo pipefail

IMAGE="local/pwn"

if ! podman image exists "${IMAGE}"; then
    echo "❌ Missing container image: ${IMAGE}"
    echo ""
    echo "Build it first with:"
    echo "  pwn-build"
    exit 1
fi

# Use supplied directory or current directory
WORKDIR="${1:-$PWD}"

if [ ! -d "${WORKDIR}" ]; then
    echo "❌ Directory does not exist:"
    echo "  ${WORKDIR}"
    exit 1
fi

echo "🐳 Entering pwn environment"
echo "📂 Mounted:"
echo "  ${WORKDIR}"
echo ""

podman run \
    --rm \
    -it \
    \
    --users=keep-id \
    --network=none \
    --cap-drop=ALL \
    --security-opt=no-new-privileges \
    \
    --read-only \
    --tmpfs /tmp \
    \
    -v "${WORKDIR}:/work:Z" \
    -w /work \
    \
    "${IMAGE}"
