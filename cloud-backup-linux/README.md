# Cloud Backup Linux

Projeto para executar backups de bancos **Informix** e **PostgreSQL** e enviar os arquivos para um servidor remoto usando `rsync` sobre SSH.

O repositório foi estruturado a partir de uma documentação operacional legada, mas com melhorias de segurança, validação, logs e configuração centralizada.

## Recursos

- Criação do usuário de serviço `backup`.
- Autenticação SSH por chave, sem senha interativa.
- Backup Informix com `ontape`.
- Backup PostgreSQL com `pg_dump`.
- Envio para nuvem com `rsync` ou `scp`.
- Logs separados por execução.
- Validação de comandos, diretórios e arquivos.
- Bloqueio contra duas execuções simultâneas.
- Configuração por arquivo `/etc/cloud-backup/backup.env`.
- Exemplos de agendamento no `cron`.

## Estrutura

```text
cloud-backup-linux/
├── config/
│   └── backup.env.example
├── cron/
│   └── backup.cron.example
├── docs/
│   ├── INSTALLATION.md
│   ├── INFORMIX.md
│   ├── POSTGRESQL.md
│   ├── SECURITY.md
│   └── TROUBLESHOOTING.md
├── scripts/
│   ├── common.sh
│   ├── install.sh
│   ├── setup-backup-user.sh
│   ├── upload-to-cloud.sh
│   ├── validate-backup.sh
│   ├── informix/
│   │   ├── create-informix-backup.sh
│   │   └── run-informix-backup.sh
│   └── postgres/
│       ├── create-postgres-backup.sh
│       └── run-postgres-backup.sh
├── .gitignore
├── LICENSE
└── README.md
```

## Instalação rápida

> Execute como `root`.

```bash
git clone <URL_DO_REPOSITORIO>
cd cloud-backup-linux
chmod +x scripts/*.sh scripts/informix/*.sh scripts/postgres/*.sh
sudo ./scripts/install.sh
```

Depois edite:

```bash
sudo vi /etc/cloud-backup/backup.env
```

Campos essenciais:

```bash
CLOUD_HOST="SEU_SERVIDOR"
CLOUD_PORT="22"
CLOUD_USER="backup"
CLOUD_CLIENT_DIR="nome_do_cliente"
```

## Configurar acesso SSH

A opção recomendada é gerar uma chave no cliente e copiar somente a chave pública para a nuvem:

```bash
sudo -u backup ssh-keygen -t ed25519 -f /home/backup/.ssh/id_ed25519 -N ""
sudo -u backup ssh-copy-id -i /home/backup/.ssh/id_ed25519.pub backup@SEU_SERVIDOR
```

Teste:

```bash
sudo -u backup ssh backup@SEU_SERVIDOR 'echo conexão OK'
```

Também é possível importar uma pasta `.ssh` existente, mas isso deve ser feito com extremo cuidado. Consulte [docs/SECURITY.md](docs/SECURITY.md).

## Executar manualmente

### Informix

```bash
sudo /usr/local/sbin/cloud-backup-informix
```

### PostgreSQL

```bash
sudo /usr/local/sbin/cloud-backup-postgres
```

### Validar ambiente

```bash
sudo /usr/local/sbin/cloud-backup-validate informix
sudo /usr/local/sbin/cloud-backup-validate postgres
```

## Agendamento sugerido

```cron
00 22 * * * root /usr/local/sbin/cloud-backup-informix
00 01 * * * root /usr/local/sbin/cloud-backup-postgres
```

Copie o exemplo:

```bash
sudo cp cron/backup.cron.example /etc/cron.d/cloud-backup
sudo chmod 0644 /etc/cron.d/cloud-backup
```

## Onde ficam os logs

```text
/var/log/cloud-backup/informix.log
/var/log/cloud-backup/postgres.log
/var/log/cloud-backup/upload.log
```

## Segurança

Este projeto **não armazena senhas no Git**. Não publique senhas, chaves privadas ou arquivos `.env` reais no repositório.

A documentação original utilizava permissões `777`. Neste projeto, elas foram substituídas por permissões mais restritas sempre que possível.

## Licença

MIT. Consulte [LICENSE](LICENSE).
