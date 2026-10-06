#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
load_config

if [[ $# -lt 1 ]]; then
  echo "Uso: $0 ARQUIVO [ARQUIVO...]" >&2
  exit 2
fi

ensure_dir "$LOG_ROOT" 0750
exec >>"$LOG_ROOT/upload.log" 2>&1

require_command ssh
case "$CLOUD_TRANSFER_METHOD" in
  rsync) require_command rsync ;;
  scp) require_command scp ;;
  *) log ERROR "Método inválido: $CLOUD_TRANSFER_METHOD"; exit 1 ;;
esac

if [[ "$VERIFY_REMOTE_CHECKSUM" == "yes" ]]; then
  require_command sha256sum
fi

mapfile -t SSH_ARGS < <(ssh_base_args)
REMOTE_DIR="$(remote_target_dir)"

log INFO "Validando conexão SSH com $CLOUD_USER@$CLOUD_HOST:$CLOUD_PORT"
run_as_user "$BACKUP_USER" ssh "${SSH_ARGS[@]}" "$CLOUD_USER@$CLOUD_HOST" "mkdir -p '$REMOTE_DIR' && test -w '$REMOTE_DIR'"

for file in "$@"; do
  if [[ ! -f "$file" ]]; then
    log ERROR "Arquivo não encontrado: $file"
    exit 1
  fi

  log INFO "Enviando: $file"
  if [[ "$CLOUD_TRANSFER_METHOD" == "rsync" ]]; then
    run_as_user "$BACKUP_USER" rsync -azP \
      -e "ssh -p $CLOUD_PORT -o BatchMode=yes -o ConnectTimeout=$SSH_CONNECT_TIMEOUT -o StrictHostKeyChecking=$SSH_STRICT_HOST_KEY_CHECKING -o UserKnownHostsFile=$SSH_KNOWN_HOSTS_FILE" \
      -- "$file" "$CLOUD_USER@$CLOUD_HOST:$REMOTE_DIR/"
  else
    run_as_user "$BACKUP_USER" scp \
      -P "$CLOUD_PORT" \
      -o BatchMode=yes \
      -o "ConnectTimeout=$SSH_CONNECT_TIMEOUT" \
      -o "StrictHostKeyChecking=$SSH_STRICT_HOST_KEY_CHECKING" \
      -o "UserKnownHostsFile=$SSH_KNOWN_HOSTS_FILE" \
      -- "$file" "$CLOUD_USER@$CLOUD_HOST:$REMOTE_DIR/"
  fi

  remote_name="$(basename "$file")"

  if [[ "$VERIFY_REMOTE_AFTER_UPLOAD" == "yes" ]]; then
    local_size="$(stat -c '%s' "$file")"
    remote_size="$(run_as_user "$BACKUP_USER" ssh "${SSH_ARGS[@]}" "$CLOUD_USER@$CLOUD_HOST" "stat -c '%s' '$REMOTE_DIR/$remote_name'")"
    if [[ "$local_size" != "$remote_size" ]]; then
      log ERROR "Tamanho divergente para $remote_name: local=$local_size remoto=$remote_size"
      exit 1
    fi
    log INFO "Tamanho validado no servidor remoto: $remote_name ($remote_size bytes)"
  fi

  if [[ "$VERIFY_REMOTE_CHECKSUM" == "yes" ]]; then
    local_sha="$(sha256sum "$file" | awk '{print $1}')"
    remote_sha="$(run_as_user "$BACKUP_USER" ssh "${SSH_ARGS[@]}" "$CLOUD_USER@$CLOUD_HOST" "sha256sum '$REMOTE_DIR/$remote_name' | awk '{print \\$1}'")"
    if [[ "$local_sha" != "$remote_sha" ]]; then
      log ERROR "Checksum SHA-256 divergente para $remote_name"
      exit 1
    fi
    log INFO "Checksum SHA-256 validado: $remote_name"
  fi

  if [[ "$DELETE_LOCAL_AFTER_UPLOAD" == "yes" ]]; then
    rm -f -- "$file"
    log INFO "Arquivo local removido após confirmação: $file"
  fi
done

log INFO "Envio concluído com sucesso."
