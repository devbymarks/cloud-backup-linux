#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
load_config

require_commands rsync ssh stat awk find sort head cut

IFX_PATTERN="${INFORMIX_BACKUP_PATTERN:-server-bd_0_L0*}"
PG_PATTERN="${POSTGRES_BACKUP_PATTERN:-bkp_logus*}"

log INFO "Iniciando backup remoto Informix + PostgreSQL"
prepare_remote_dir

IFX="$(find_latest "$IFX_PATTERN")"
PG="$(find_latest "$PG_PATTERN")"

[[ -n "$IFX" ]] || die "Nenhum backup Informix encontrado."
[[ -n "$PG" ]] || die "Nenhum backup PostgreSQL encontrado."

# Cada backup é validado antes da retenção.
send_and_verify "$IFX"
send_and_verify "$PG"

# Arquivos auxiliares compartilhados do ambiente Informix.
for file in \
    "${BACKUP_ROOT}/database" \
    "${BACKUP_ROOT}/sqlhosts" \
    "${BACKUP_ROOT}/onconfig.ol_matriz"
do
    [[ -f "$file" ]] || die "Arquivo auxiliar não encontrado: $file"
    send_and_verify "$file"
done

# Retenção: somente após transferência + validação.
remove_old_remote_backups "$IFX_PATTERN" 1
remove_old_remote_backups "$PG_PATTERN" 1

log INFO "Backup Informix + PostgreSQL concluído com sucesso"
exit 0
