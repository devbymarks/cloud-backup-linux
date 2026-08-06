#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../common.sh
source "$SCRIPT_DIR/common.sh"
load_config

: "${POSTGRES_DB:?}"
: "${POSTGRES_BACKUP_DIR:?}"
: "${POSTGRES_BACKUP_PREFIX:=bkp_logus}"
: "${POSTGRES_FORMAT:=custom}"

require_command pg_dump
ensure_dir "$POSTGRES_BACKUP_DIR" 0750

weekday="$(LC_ALL=C date +%A | tr '[:upper:]' '[:lower:]')"
timestamp="$(date '+%Y%m%d_%H%M%S')"

case "$POSTGRES_FORMAT" in
  custom)
    output="$POSTGRES_BACKUP_DIR/${POSTGRES_BACKUP_PREFIX}_${weekday}_${timestamp}.dump"
    pg_dump -Fc "$POSTGRES_DB" > "$output"
    ;;
  plain)
    output="$POSTGRES_BACKUP_DIR/${POSTGRES_BACKUP_PREFIX}_${weekday}_${timestamp}.sql.gz"
    require_command gzip
    pg_dump "$POSTGRES_DB" | gzip -c > "$output"
    ;;
  *)
    log ERROR "POSTGRES_FORMAT inválido: $POSTGRES_FORMAT"
    exit 1
    ;;
esac

[[ -s "$output" ]] || { log ERROR "Backup PostgreSQL vazio: $output"; exit 1; }
printf '%s\n' "$output"
