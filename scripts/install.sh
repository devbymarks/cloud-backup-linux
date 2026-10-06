#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Execute como root." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_DIR="/opt/cloud-backup"
CONFIG_DIR="/etc/cloud-backup"

"$SCRIPT_DIR/setup-backup-user.sh"

install -d -m 0755 "$INSTALL_DIR" "$CONFIG_DIR"
cp -a "$PROJECT_DIR/scripts" "$INSTALL_DIR/"
chmod 0755 "$INSTALL_DIR/scripts"/*.sh "$INSTALL_DIR/scripts/informix"/*.sh "$INSTALL_DIR/scripts/postgres"/*.sh

if [[ ! -f "$CONFIG_DIR/backup.env" ]]; then
  install -m 0640 -o root -g backup "$PROJECT_DIR/config/backup.env.example" "$CONFIG_DIR/backup.env"
fi

install -d -m 0750 -o root -g backup /var/log/cloud-backup
install -d -m 0755 /var/lock/cloud-backup
install -d -m 0770 -o backup -g backup /opt/backup /opt/tmp

ln -sfn "$INSTALL_DIR/scripts/informix/run-informix-backup.sh" /usr/local/sbin/cloud-backup-informix
ln -sfn "$INSTALL_DIR/scripts/postgres/run-postgres-backup.sh" /usr/local/sbin/cloud-backup-postgres
ln -sfn "$INSTALL_DIR/scripts/validate-backup.sh" /usr/local/sbin/cloud-backup-validate
ln -sfn "$INSTALL_DIR/scripts/upload-to-cloud.sh" /usr/local/sbin/cloud-backup-upload

cat <<MSG
Instalação concluída.

Próximos passos:
1. Edite $CONFIG_DIR/backup.env
2. Configure a chave SSH do usuário backup
3. Crie o diretório remoto do cliente
4. Execute: cloud-backup-validate all
5. Teste manualmente os backups
6. Instale o cron usando cron/backup.cron.example
MSG
