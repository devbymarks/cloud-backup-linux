#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../common.sh
source "$SCRIPT_DIR/common.sh"
load_config
acquire_lock informix

ensure_dir "$LOG_ROOT" 0750
exec >>"$LOG_ROOT/informix.log" 2>&1

if [[ "${INFORMIX_ENABLED:-yes}" != "yes" ]]; then
  log INFO "Backup Informix desabilitado."
  exit 0
fi

: "${INFORMIX_USER:=informix}"
: "${INFORMIX_BACKUP_DIR:?}"

ensure_dir "$INFORMIX_BACKUP_DIR" 0770
chown "$INFORMIX_USER:$BACKUP_GROUP" "$INFORMIX_BACKUP_DIR"

log INFO "Iniciando rotina Informix"
run_as_user "$INFORMIX_USER" "$SCRIPT_DIR/informix/create-informix-backup.sh"

mapfile -t files < <(find "$INFORMIX_BACKUP_DIR" -maxdepth 1 -type f \( \
  -name "${INFORMIX_BACKUP_PREFIX}_*" -o \
  -name "$INFORMIX_ONCONFIG" -o \
  -name "sqlhosts" -o \
  -name "database.txt" \
\) -print)

if [[ ${#files[@]} -eq 0 ]]; then
  log ERROR "Nenhum arquivo Informix encontrado para envio."
  exit 1
fi

chown "$BACKUP_USER:$BACKUP_GROUP" "${files[@]}"
chmod 0640 "${files[@]}"
"$SCRIPT_DIR/upload-to-cloud.sh" "${files[@]}"

if [[ "${LOCAL_RETENTION_DAYS:-0}" =~ ^[0-9]+$ ]] && (( LOCAL_RETENTION_DAYS > 0 )); then
  find "$INFORMIX_BACKUP_DIR" -maxdepth 1 -type f -mtime "+$LOCAL_RETENTION_DAYS" -delete
fi

log INFO "Rotina Informix concluída."
