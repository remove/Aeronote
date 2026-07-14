#!/usr/bin/env bash
set -euo pipefail

release_id=${1:?release ID is required}

if [[ ! $release_id =~ ^[0-9a-f]{40}-[1-9][0-9]*$ ]]; then
  echo "Invalid release ID: $release_id" >&2
  exit 2
fi

base=/srv/aeronote
archive="$base/shared/aeronote-$release_id.tar.gz"
checksum="$archive.sha256"
release="$base/releases/$release_id"

test -f "$archive"
test -f "$checksum"
test ! -e "$release"

cd "$base/shared"
sha256sum --check "${checksum##*/}"

mkdir "$release"
tar --extract --gzip --file="$archive" --directory="$release" \
  --no-same-owner --no-same-permissions
test -s "$release/index.html"

ln -sfn "releases/$release_id" "$base/current.next"
mv -Tf "$base/current.next" "$base/current"

rm -- "$archive" "$checksum"

printf 'Activated Aeronote release %s\n' "$release_id"
