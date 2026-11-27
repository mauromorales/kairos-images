#!/usr/bin/env bash
# Test newest-upstream-tag.sh with fixed tag lists. No network.
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
list="$(mktemp)"
trap 'rm -f "$list"' EXIT
fail=0

# check <name> <expected tag, or empty for "must fail"> <tag>...
check() {
  local name="$1" want="$2" got status
  shift 2
  printf '%s\n' "$@" > "$list"
  got="$("$here/newest-upstream-tag.sh" "$list" 2>/dev/null)"
  status=$?
  if { [ -n "$want" ] && [ "$status" -eq 0 ] && [ "$got" = "$want" ]; } ||
     { [ -z "$want" ] && [ "$status" -ne 0 ] && [ -z "$got" ]; }; then
    echo "PASS  $name"
  else
    echo "FAIL  $name: want '${want:-an error}', got '$got' (exit $status)"
    fail=1
  fi
}

t() { echo "v$1-standard-amd64-generic-v$2-k0s-v$3"; }

check "the highest Kairos version wins, compared as numbers" "$(t 0.6.3 4.10.0 1.36.6-k0s.0)" \
  "$(t 0.6.3 4.9.0 1.36.6-k0s.0)" "$(t 0.6.3 4.10.0 1.36.6-k0s.0)" "$(t 0.6.3 4.5.2 1.36.6-k0s.0)"
check "a release candidate is skipped" "$(t 0.6.3 4.6.0 1.36.6-k0s.0)" \
  "$(t 0.6.3 4.6.0 1.36.6-k0s.0)" "$(t 0.6.3 4.7.0-rc1 1.36.6-k0s.0)"
check "another k0s minor version is skipped" "$(t 0.6.3 4.6.0 1.36.6-k0s.0)" \
  "$(t 0.6.3 4.6.0 1.36.6-k0s.0)" "$(t 0.6.3 4.7.0 1.37.2-k0s.1)"
check "Kairos 5 and Kairos before 4.5.0 are skipped" "$(t 0.6.3 4.5.0 1.36.6-k0s.0)" \
  "$(t 0.6.3 4.5.0 1.36.6-k0s.0)" "$(t 0.7.0 5.0.0 1.36.6-k0s.0)" "$(t 0.6.3 4.4.0 1.36.9-k0s.0)"
check "another variant is skipped" "$(t 0.6.3 4.5.0 1.36.6-k0s.0)" \
  "$(t 0.6.3 4.5.0 1.36.6-k0s.0)" \
  "v0.6.3-standard-arm64-generic-v4.7.0-k0s-v1.36.6-k0s.0" \
  "v0.6.3-standard-amd64-generic-v4.7.0-k0s-v1.36.6-k0s.0-uki"
check "same Kairos version: the higher k0s version wins" "$(t 0.6.3 4.7.0 1.36.6-k0s.1)" \
  "$(t 0.6.3 4.7.0 1.36.6-k0s.1)" "$(t 0.6.3 4.7.0 1.36.6-k0s.0)" "$(t 0.6.4 4.7.0 1.36.4-k0s.9)"
check "same Kairos and k0s version: the higher Hadron version wins" "$(t 0.6.10 4.7.0 1.36.6-k0s.0)" \
  "$(t 0.6.10 4.7.0 1.36.6-k0s.0)" "$(t 0.6.9 4.7.0 1.36.6-k0s.0)"
check "no match is an error" "" "latest" "$(t 0.6.3 4.7.0 1.37.2-k0s.1)"

exit "$fail"
