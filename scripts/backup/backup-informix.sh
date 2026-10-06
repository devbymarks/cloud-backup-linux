#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
load_config

require_commands rsync ssh stat awk find sort head cut

IFX_PATTERN="${INFORMIX_BACKUP_PATTERN:-server-bd_0_L0*}"
IFX_AUXILIARIES=(
    "${BACKUP_ROOT}/database"
    "${BACKUP_ROOT}/sqlhosts"
    "${BACKUP_ROOT}/onconfig.ol_matriz"
)

log INFO "Iniciando backup remoto somente Informix"
prepare_remote_dir

BACKUP="$(find_latest "$IFX_PATTERN")"
[[ -n "$BACKUP" ]] || die "Nenhum backup Informix encontrado em $BACKUP_ROOT ($IFX_PATTERN)"

# Backup principal: envia e valida antes de qualquer limpeza.
send_and_verify "$BACKUP"

# Arquivos auxiliares: rsync sobrescreve os mesmos nomes, mantendo somente 1 cópia.
for file in "${IFX_AUXILIARIES[@]}"; do
    [[ -f "$file" ]] || die "Arquivo auxiliar não encontrado: $file"
    send_and_verify "$file"
done

# Só depois da validação do novo backup, mantém apenas o mais recente.
remove_old_remote_backups "$IFX_PATTERN" 1

log INFO "Backup Informix concluído com sucesso"
exit 0
