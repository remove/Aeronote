#!/usr/bin/env bash
set -euo pipefail

origin=(--resolve aeronote.net:443:127.0.0.1)

curl --fail --silent --show-error "${origin[@]}" \
  "https://aeronote.net/healthz" | grep -qx 'ok'

curl --fail --silent --show-error "${origin[@]}" \
  --output /dev/null \
  "https://aeronote.net/"

printf 'Aeronote origin verification passed\n'
