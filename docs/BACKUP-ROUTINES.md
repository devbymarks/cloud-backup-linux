# Rotinas de Backup

## Estrutura

```text
scripts/
├── lib/
│   └── common.sh
└── backup/
    ├── backup-informix.sh
    ├── backup-informix-postgres.sh
    └── backup-postgres.sh
```

## Fluxo

1. Localiza o backup mais recente no `/opt/backup`.
2. Garante que o diretório do cliente existe no servidor remoto.
3. Envia com `rsync`.
4. Confere tamanho local x remoto.
5. Confere SHA-256 local x remoto.
6. Somente depois da validação, remove backups antigos.
7. Os arquivos auxiliares (`database`, `sqlhosts` e `onconfig.ol_matriz`) usam sempre o mesmo nome remoto e, portanto, ficam com uma única cópia.

## Retenção

As três rotinas mantêm **1 backup remoto mais recente** do tipo correspondente.

A limpeza nunca acontece antes da validação do arquivo recém-enviado.

## Configuração

Edite `/etc/cloud-backup/backup.env`:

```bash
CLOUD_HOST="backup.example.com"
CLOUD_USER="backup"
CLOUD_BASE_DIR="/backup/clientes"
CLOUD_CLIENT_DIR="cliente_exemplo"
BACKUP_ROOT="/opt/backup"

INFORMIX_BACKUP_PATTERN="server-bd_0_L0*"
POSTGRES_BACKUP_PATTERN="bkp_logus*"
VERIFY_REMOTE_CHECKSUM="yes"
```

## Execução

```bash
/opt/cloud-backup/scripts/backup/backup-informix.sh
/opt/cloud-backup/scripts/backup/backup-informix-postgres.sh
/opt/cloud-backup/scripts/backup/backup-postgres.sh
```

## Vantagens

- Não há IP, cliente ou senha dentro dos scripts.
- A lógica de SSH/rsync fica centralizada.
- O mesmo padrão pode ser reutilizado para vários clientes.
- O backup remoto é validado antes da retenção.
- Falhas interrompem a rotina com código diferente de zero.
