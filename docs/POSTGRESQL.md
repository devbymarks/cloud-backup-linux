# PostgreSQL

## Configuração

No arquivo `/etc/cloud-backup/backup.env`:

```bash
POSTGRES_USER="postgres"
POSTGRES_DB="example_database"
POSTGRES_BACKUP_DIR="/opt/backup/postgres"
POSTGRES_BACKUP_PREFIX="postgres_backup"
POSTGRES_FORMAT="custom"
```

## Formatos

- `custom`: usa `pg_dump -Fc` e gera `.dump`.
- `plain`: gera SQL compactado em `.sql.gz`.

## Execução

```bash
sudo cloud-backup-postgres
```

## Restauração de exemplo

Formato custom:

```bash
createdb banco_restaurado
pg_restore -d banco_restaurado arquivo.dump
```

Formato SQL compactado:

```bash
gzip -dc arquivo.sql.gz | psql banco_restaurado
```
