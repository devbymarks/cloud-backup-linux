#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
load_config

mode="${1:-all}"
errors=0

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    printf '[OK] comando: %s\n' "$1"
  else
    printf '[ERRO] comando ausente: %s\n' "$1"
    errors=$((errors + 1))
  fi
}

check_dir() {
  if [[ -d "$1" ]]; then
    printf '[OK] diretório: %s\n' "$1"
  else
    printf '[ERRO] diretório ausente: %s\n' "$1"
    errors=$((errors + 1))
  fi
}

check_cmd ssh
check_cmd flock
[[ "$CLOUD_TRANSFER_METHOD" == "rsync" ]] && check_cmd rsync || check_cmd scp
check_dir "$BACKUP_HOME/.ssh"

if [[ "$mode" == "informix" || "$mode" == "all" ]]; then
  check_cmd ontape
  check_cmd onstat
  check_dir "$INFORMIX_DIR"
  check_dir "$(dirname "$INFORMIX_SQLHOSTS")"
fi

if [[ "$mode" == "postgres" || "$mode" == "all" ]]; then
  check_cmd pg_dump
  id "$POSTGRES_USER" >/dev/null 2>&1 || { echo "[ERRO] usuário ausente: $POSTGRES_USER"; errors=$((errors + 1)); }
fi

mapfile -t SSH_ARGS < <(ssh_base_args)
if run_as_user "$BACKUP_USER" ssh "${SSH_ARGS[@]}" "$CLOUD_USER@$CLOUD_HOST" 'true'; then
  echo "[OK] conexão SSH"
else
  echo "[ERRO] conexão SSH"
  errors=$((errors + 1))
fi

if (( errors > 0 )); then
  echo "Validação concluída com $errors erro(s)."
  exit 1
fi

echo "Validação concluída sem erros."
