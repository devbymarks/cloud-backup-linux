#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
status=0

printf 'Validando sintaxe dos scripts Bash...\n'
while IFS= read -r -d '' script; do
  if bash -n "$script"; then
    printf '[OK] %s\n' "${script#"$ROOT_DIR/"}"
  else
    printf '[ERRO] %s\n' "${script#"$ROOT_DIR/"}" >&2
    status=1
  fi
done < <(find "$ROOT_DIR/scripts" -type f -name '*.sh' -print0)

exit "$status"
