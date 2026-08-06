#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../common.sh
source "$SCRIPT_DIR/common.sh"
load_config

: "${INFORMIX_SERVER:?}"
: "${INFORMIX_DIR:?}"
: "${INFORMIX_ONCONFIG:?}"
: "${INFORMIX_SQLHOSTS:?}"
: "${INFORMIX_BACKUP_DIR:?}"
: "${INFORMIX_BACKUP_PREFIX:=xlogus}"
: "${INFORMIX_LEVEL:=0}"

export INFORMIXSERVER="$INFORMIX_SERVER"
export INFORMIXDIR="$INFORMIX_DIR"
export ONCONFIG="$INFORMIX_ONCONFIG"
export INFORMIXSQLHOSTS="$INFORMIX_SQLHOSTS"
export PATH="$PATH:$INFORMIXDIR/bin"

require_command ontape
require_command onstat
ensure_dir "$INFORMIX_BACKUP_DIR" 0750
cd "$INFORMIX_BACKUP_DIR"

log INFO "Configurações de backup do Informix"
onstat -c | grep -E '^L?TAPE|^BACKUP_FILTER|^RESTORE_FILTER' || true

log INFO "Backup Informix iniciado"
rm -f -- "${INFORMIX_BACKUP_PREFIX}"_0_20* "${INFORMIX_BACKUP_PREFIX}"_0_L0* 2>/dev/null || true
ontape -s -L "$INFORMIX_LEVEL"

onstat -d > database.txt
cp -f "$INFORMIX_DIR/etc/$INFORMIX_ONCONFIG" .
cp -f "$INFORMIX_SQLHOSTS" ./sqlhosts

log INFO "Backup Informix finalizado"
