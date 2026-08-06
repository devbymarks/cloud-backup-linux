#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../common.sh
source "$SCRIPT_DIR/common.sh"
load_config
acquire_lock postgres

ensure_dir "$LOG_ROOT" 0750
exec >>"$LOG_ROOT/postgres.log" 2>&1

if [[ "${POSTGRES_ENABLED:-yes}" != "yes" ]]; then
  log INFO "Backup PostgreSQL desabilitado."
  exit 0
fi

: "${POSTGRES_USER:=postgres}"
: "${POSTGRES_BACKUP_DIR:?}"

ensure_dir "$POSTGRES_BACKUP_DIR" 0770
chown "$POSTGRES_USER:$BACKUP_GROUP" "$POSTGRES_BACKUP_DIR"

log INFO "Iniciando rotina PostgreSQL"
output="$(run_as_user "$POSTGRES_USER" "$SCRIPT_DIR/postgres/create-postgres-backup.sh" | tail -n 1)"

if [[ ! -s "$output" ]]; then
  log ERROR "Arquivo PostgreSQL não foi criado corretamente: $output"
  exit 1
fi

chown "$BACKUP_USER:$BACKUP_GROUP" "$output"
chmod 0640 "$output"
"$SCRIPT_DIR/upload-to-cloud.sh" "$output"

if [[ "${LOCAL_RETENTION_DAYS:-0}" =~ ^[0-9]+$ ]] && (( LOCAL_RETENTION_DAYS > 0 )); then
  find "$POSTGRES_BACKUP_DIR" -maxdepth 1 -type f -mtime "+$LOCAL_RETENTION_DAYS" -delete
fi

log INFO "Rotina PostgreSQL concluída."
