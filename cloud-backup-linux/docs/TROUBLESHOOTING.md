# Solução de problemas

## SSH pede senha

```bash
sudo -u backup ssh -vvv backup@backup.example.com
```

Confira:

```bash
ls -ld /home/backup/.ssh
ls -l /home/backup/.ssh
```

Permissões esperadas:

```bash
chmod 0700 /home/backup/.ssh
chmod 0600 /home/backup/.ssh/id_ed25519
chown -R backup:backup /home/backup/.ssh
```

## `Permission denied` no diretório local

Confira proprietário e grupo:

```bash
chown -R informix:backup /opt/backup/informix
chown -R postgres:backup /opt/backup/postgres
chmod -R 0770 /opt/backup
```

## Informix não gera o arquivo esperado

- Confirme `TAPEDEV` no `onconfig`.
- Confirme `INFORMIXSERVER`.
- Confira `onstat -c`.
- Leia `/var/log/cloud-backup/informix.log`.

## PostgreSQL falha no `pg_dump`

Teste como usuário postgres:

```bash
sudo -u postgres pg_dump -Fc example_database >/tmp/teste.dump
```

Confira autenticação local no `pg_hba.conf`.

## Arquivo enviado para pasta errada

Revise:

```bash
CLOUD_BASE_DIR
CLOUD_CLIENT_DIR
```

O destino final será:

```text
CLOUD_BASE_DIR/CLOUD_CLIENT_DIR
```
