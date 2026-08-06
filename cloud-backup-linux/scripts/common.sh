#!/usr/bin/env bash
set -Eeuo pipefail

CONFIG_FILE="${CONFIG_FILE:-/etc/cloud-backup/backup.env}"

load_config() {
  if [[ ! -r "$CONFIG_FILE" ]]; then
    echo "ERRO: arquivo de configuração não encontrado: $CONFIG_FILE" >&2
    exit 1
  fi

  # shellcheck disable=SC1090
  source "$CONFIG_FILE"

  : "${CLOUD_HOST:?CLOUD_HOST não definido}"
  : "${CLOUD_USER:?CLOUD_USER não definido}"
  : "${CLOUD_CLIENT_DIR:?CLOUD_CLIENT_DIR não definido}"
  : "${BACKUP_USER:=backup}"
  : "${BACKUP_GROUP:=backup}"
  : "${BACKUP_HOME:=/home/backup}"
  : "${LOG_ROOT:=/var/log/cloud-backup}"
  : "${LOCK_ROOT:=/var/lock/cloud-backup}"
  : "${CLOUD_PORT:=22}"
  : "${SSH_CONNECT_TIMEOUT:=20}"
  : "${CLOUD_TRANSFER_METHOD:=rsync}"
  : "${VERIFY_REMOTE_AFTER_UPLOAD:=yes}"
  : "${DELETE_LOCAL_AFTER_UPLOAD:=no}"
}

ensure_dir() {
  local dir="$1"
  local mode="${2:-0750}"
  install -d -m "$mode" "$dir"
}

log() {
  local level="$1"
  shift
  printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*"
}

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    log ERROR "Comando obrigatório não encontrado: $cmd"
    exit 1
  }
}

acquire_lock() {
  local name="$1"
  ensure_dir "$LOCK_ROOT" 0755
  exec 9>"$LOCK_ROOT/$name.lock"
  if ! flock -n 9; then
    log ERROR "Já existe uma execução em andamento: $name"
    exit 1
  fi
}

run_as_user() {
  local user="$1"
  shift
  if command -v runuser >/dev/null 2>&1; then
    runuser -u "$user" -- "$@"
  else
    su -s /bin/bash "$user" -c "$(printf '%q ' "$@")"
  fi
}

remote_target_dir() {
  printf '%s/%s' "${CLOUD_BASE_DIR%/}" "${CLOUD_CLIENT_DIR#/}"
}

ssh_base_args() {
  printf '%s\n' \
    "-p" "$CLOUD_PORT" \
    "-o" "BatchMode=yes" \
    "-o" "ConnectTimeout=$SSH_CONNECT_TIMEOUT" \
    "-o" "StrictHostKeyChecking=accept-new"
}
