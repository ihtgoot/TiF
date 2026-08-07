#!/usr/bin/env bash
set -e

[ $# -eq 1 ] || { echo "Usage: $0 <docker-image>"; exit 1; }

IMAGE="$1"
ROOTFS="rootfs"

CID=$(docker create "$IMAGE")
mkdir -p "$ROOTFS"
docker export "$CID" | tar -xf - -C "$ROOTFS"
docker rm "$CID" >/dev/null

echo "Extracted '$IMAGE' -> $ROOTFS"
