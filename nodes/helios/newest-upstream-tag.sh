#!/usr/bin/env bash
# Print the newest upstream Hadron tag that the helios image follows.
# Usage: newest-upstream-tag.sh [tag-list-file]
# Without a file, the tags come from the quay.io API. The file holds one tag per line.
#
# Followed tags: amd64 generic standard with k0s v1.36, Kairos 4.x from 4.5.0. Release candidates
# and other variants do not match. The newest has the highest Kairos version, then the highest
# k0s version, then the highest Hadron version.
# A new k0s minor version or a new Kairos major version needs a change to the pattern.
set -euo pipefail

repo="kairos/hadron"
pattern='^v([0-9]+)\.([0-9]+)\.([0-9]+)-standard-amd64-generic-v4\.([0-9]+)\.([0-9]+)-k0s-v1\.36\.([0-9]+)-k0s\.([0-9]+)$'
min_kairos_minor=5

fetch_tags() {
  local page=1 body
  while :; do
    body="$(curl -fsS --retry 3 --max-time 60 \
      "https://quay.io/api/v1/repository/${repo}/tag/?limit=100&onlyActiveTags=true&filter_tag_name=like:-k0s-v1.36.&page=${page}")"
    jq -r '.tags[].name' <<<"$body"
    [ "$(jq -r '.has_additional' <<<"$body")" = "true" ] || break
    page=$((page + 1))
    if [ "$page" -gt 100 ]; then
      echo "Too many tag pages from quay.io." >&2; return 1
    fi
  done
}

if [ $# -gt 0 ]; then
  tags="$(cat "$1")"
else
  tags="$(fetch_tags)"
fi

newest="$(
  while IFS= read -r tag; do
    [[ "$tag" =~ $pattern ]] || continue
    m=("${BASH_REMATCH[@]}")
    [ "${m[4]}" -ge "$min_kairos_minor" ] || continue
    # Kairos minor and patch, k8s patch, k0s revision, then Hadron.
    echo "${m[4]} ${m[5]} ${m[6]} ${m[7]} ${m[1]} ${m[2]} ${m[3]} ${tag}"
  done <<<"$tags" |
    sort -k1,1n -k2,2n -k3,3n -k4,4n -k5,5n -k6,6n -k7,7n |
    tail -n 1 | awk '{print $8}'
)"

if [ -z "$newest" ]; then
  echo "No upstream tag matches ${pattern}." >&2
  exit 1
fi
echo "$newest"
