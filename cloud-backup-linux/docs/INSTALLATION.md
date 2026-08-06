# Instalação

## 1. Requisitos

- Linux com Bash.
- Acesso `root`.
- `openssh-client`.
- `rsync` ou `scp`.
- Para Informix: `ontape` e `onstat`.
- Para PostgreSQL: `pg_dump`.

## 2. Instalar

```bash
chmod +x scripts/*.sh scripts/informix/*.sh scripts/postgres/*.sh
sudo ./scripts/install.sh
```

## 3. Configurar

```bash
sudo vi /etc/cloud-backup/backup.env
```

Ajuste especialmente:

- `CLOUD_HOST`
- `CLOUD_PORT`
- `CLOUD_CLIENT_DIR`
- caminhos locais de backup
- nome do banco PostgreSQL
- variáveis do Informix

## 4. Chave SSH

```bash
sudo -u backup ssh-keygen -t ed25519 -f /home/backup/.ssh/id_ed25519 -N ""
sudo -u backup ssh-copy-id backup@HOST_DA_NUVEM
```

## 5. Criar diretório remoto

No servidor de nuvem:

```bash
mkdir -p /home/backup/NOME_DO_CLIENTE
chown backup:backup /home/backup/NOME_DO_CLIENTE
chmod 0750 /home/backup/NOME_DO_CLIENTE
```

## 6. Validar

```bash
sudo cloud-backup-validate all
```

## 7. Testar

```bash
sudo cloud-backup-informix
sudo cloud-backup-postgres
```

## 8. Agendar

```bash
sudo cp cron/backup.cron.example /etc/cron.d/cloud-backup
sudo chmod 0644 /etc/cron.d/cloud-backup
```
