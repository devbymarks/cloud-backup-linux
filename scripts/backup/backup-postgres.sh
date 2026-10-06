#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
load_config

require_commands rsync ssh stat awk find sort head cut

PG_PATTERN="${POSTGRES_BACKUP_PATTERN:-bkp_logus*}"

log INFO "Iniciando backup remoto somente PostgreSQL"
prepare_remote_dir

PG="$(find_latest "$PG_PATTERN")"
[[ -n "$PG" ]] || die "Nenhum backup PostgreSQL encontrado em $BACKUP_ROOT ($PG_PATTERN)"

# Envia e valida antes de apagar qualquer versão antiga.
send_and_verify "$PG"

remove_old_remote_backups "$PG_PATTERN" 1

log INFO "Backup PostgreSQL concluído com sucesso"
exit 0
