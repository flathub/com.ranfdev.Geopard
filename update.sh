#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq moreutils

set -eu -o pipefail

manifest="com.ranfdev.Geopard.json"
owner="ranfdev"
repo="Geopard"

archive_url=$(curl "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r '.["assets"] | first | .["browser_download_url"]')
echo $archive_url;

curl -L \
  -H "Accept: application/octet-stream" \
  $archive_url > remote_archive

sha256=$(sha256sum remote_archive | awk '{print $1}')

jq --arg url $archive_url --arg sha256 $sha256 \
  '(.["modules"] | last | .["sources"] | last) |= {type: "archive", url: $url, sha256: $sha256}' \
  "$manifest" \
  | sponge "$manifest"