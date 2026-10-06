#!/usr/bin/env bash
set -Eeuo pipefail

BACKUP_USER="${BACKUP_USER:-backup}"
BACKUP_GROUP="${BACKUP_GROUP:-backup}"
BACKUP_HOME="${BACKUP_HOME:-/home/backup}"

if [[ $EUID -ne 0 ]]; then
  echo "Execute como root." >&2
  exit 1
fi

if ! getent group "$BACKUP_GROUP" >/dev/null; then
  groupadd "$BACKUP_GROUP"
fi

if ! id "$BACKUP_USER" >/dev/null 2>&1; then
  useradd -g "$BACKUP_GROUP" -d "$BACKUP_HOME" -m -s /bin/bash "$BACKUP_USER"
fi

install -d -m 0700 -o "$BACKUP_USER" -g "$BACKUP_GROUP" "$BACKUP_HOME/.ssh"
touch "$BACKUP_HOME/.ssh/known_hosts"
chown "$BACKUP_USER:$BACKUP_GROUP" "$BACKUP_HOME/.ssh/known_hosts"
chmod 0600 "$BACKUP_HOME/.ssh/known_hosts"

cat <<MSG
Usuário $BACKUP_USER preparado.

Defina uma senha somente se o seu procedimento interno exigir:
  passwd $BACKUP_USER

Recomendado: autenticação por chave SSH.
  sudo -u $BACKUP_USER ssh-keygen -t ed25519 -f $BACKUP_HOME/.ssh/id_ed25519 -N ""
MSG
