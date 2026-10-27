#!/bin/sh
# Download tagged public engine binaries and a tagged public console build.
# Inputs are GitHub release assets on apito-io/engine and apito-io/console.
# This script does not read GitLab Udbhabon studio inputs.
set -eu

ENGINE_REF="${ENGINE_REF:?set ENGINE_REF to a public engine tag}"
CONSOLE_REF="${CONSOLE_REF:?set CONSOLE_REF to a public console tag}"
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"

mkdir -p "$ROOT/engine" "$ROOT/console"
for arch in amd64 arm64; do
  curl -fL --retry 3 -o "$ROOT/engine/apito-engine-${arch}" \
    "https://github.com/apito-io/engine/releases/download/${ENGINE_REF}/apito-engine-linux-${arch}"
  chmod +x "$ROOT/engine/apito-engine-${arch}"
done

curl -fL --retry 3 -o "$ROOT/console/console-dist.tar.gz" \
  "https://github.com/apito-io/console/releases/download/${CONSOLE_REF}/console-dist.tar.gz"
rm -rf "$ROOT/console/dist"
mkdir -p "$ROOT/console/dist"
tar -xzf "$ROOT/console/console-dist.tar.gz" -C "$ROOT/console/dist"
if grep -R -l -e chatwoot -e "phc_" "$ROOT/console/dist" >/dev/null 2>&1; then
  echo "public console dist must not ship PostHog or Chatwoot" >&2
  exit 1
fi
echo "downloaded engine ${ENGINE_REF} and console ${CONSOLE_REF}"
