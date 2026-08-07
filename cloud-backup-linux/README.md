# Cloud Backup Linux

**Autor: Matheus Barcelli**

> Automação de backups em Linux para ambientes **Informix** e **PostgreSQL**, com replicação segura para servidor remoto via **SSH**, **rsync/scp**, logs, validações e agendamento.

![Linux](https://img.shields.io/badge/Linux-Bash-informational?logo=linux)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-pg__dump-informational?logo=postgresql)
![Shell](https://img.shields.io/badge/Shell-Bash-informational?logo=gnubash)
![License](https://img.shields.io/badge/License-MIT-green)
![Shell Quality](https://img.shields.io/badge/CI-ShellCheck-success?logo=githubactions)

## Sobre o projeto

Este projeto nasceu de uma **documentação operacional criada por Matheus Barcelli** para padronizar a geração e o envio de backups de bancos de dados para um servidor externo.

A documentação foi transformada em um repositório reutilizável, com foco em **Linux, administração de bancos, automação, segurança operacional e boas práticas de infraestrutura**.

A versão pública foi intencionalmente sanitizada: **não contém IPs de produção, senhas, chaves SSH ou nomes de clientes reais**.

## Problema que o projeto resolve

Em ambientes com bancos de dados locais, uma cópia mantida somente no próprio servidor não oferece isolamento suficiente contra falha de disco, indisponibilidade do host ou perda do ambiente.

O fluxo implementado automatiza:

1. geração do backup com a ferramenta nativa do banco;
2. preparação e validação dos arquivos;
3. transferência por SSH para um servidor remoto;
4. validação do envio;
5. registro de logs;
6. retenção local configurável;
7. execução periódica via `cron`.

## Arquitetura

```text
       ┌─────────────── Linux Database Server ───────────────┐
       │                                                     │
       │   Informix                         PostgreSQL        │
       │   ontape                            pg_dump          │
       │      │                                 │             │
       │      └──────────► Backup Orchestrator ◄─────────────┘
       │                         │
       │                 validation + logs
       │                         │
       │                  rsync/scp + SSH
       └─────────────────────────┼───────────────────────────┘
                                 │
                                 ▼
                       Remote Backup Server
```

Detalhes: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Principais recursos

- Backup Informix com `ontape`.
- Backup PostgreSQL com `pg_dump`.
- Transferência via `rsync` ou `scp` sobre SSH.
- Autenticação por chave SSH, sem senha gravada no código.
- Arquivo central de configuração.
- Lock com `flock` contra execuções concorrentes.
- Logs por rotina.
- Validação de dependências e conectividade.
- Verificação opcional do tamanho do arquivo remoto.
- Validação de integridade por checksum SHA-256 após a transferência.
- Retenção local configurável.
- Procedimento documentado para teste periódico de restauração.
- Instalação automatizada.
- Validação contínua com GitHub Actions, ShellCheck e scan básico de segredos.
- Agendamento por `cron`.
- Permissões mais restritas que os procedimentos legados baseados em `777`.

## Estrutura do repositório

```text
cloud-backup-linux/
├── .github/workflows/
│   └── shellcheck.yml
├── config/
│   └── backup.env.example
├── cron/
│   └── backup.cron.example
├── docs/
│   ├── ARCHITECTURE.md
│   ├── INSTALLATION.md
│   ├── INFORMIX.md
│   ├── POSTGRESQL.md
│   ├── RESTORE-TESTING.md
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
├── tests/
│   ├── security-scan.sh
│   └── smoke.sh
├── .editorconfig
├── .gitignore
├── AUTHORS.md
├── CHANGELOG.md
├── CITATION.cff
├── CONTRIBUTING.md
├── LICENSE
├── NOTICE
└── README.md
```

## Requisitos

- Linux + Bash
- acesso administrativo para instalação
- OpenSSH Client
- `rsync` ou `scp`
- `flock`
- Informix Client/Server tools (`ontape`, `onstat`) para rotina Informix
- PostgreSQL Client tools (`pg_dump`) para rotina PostgreSQL

## Instalação rápida

```bash
git clone https://github.com/SEU-USUARIO/cloud-backup-linux.git
cd cloud-backup-linux
chmod +x scripts/*.sh scripts/informix/*.sh scripts/postgres/*.sh
sudo ./scripts/install.sh
```

Edite a configuração instalada:

```bash
sudo vi /etc/cloud-backup/backup.env
```

Exemplo de configuração pública:

```bash
CLOUD_HOST="backup.example.com"
CLOUD_PORT="22"
CLOUD_USER="backup"
CLOUD_BASE_DIR="/srv/backups"
CLOUD_CLIENT_DIR="environment-example"
```

## Configuração SSH

Gere uma chave específica para o usuário de backup:

```bash
sudo -u backup ssh-keygen -t ed25519 -f /home/backup/.ssh/id_ed25519 -N ""
sudo -u backup ssh-copy-id -i /home/backup/.ssh/id_ed25519.pub backup@backup.example.com
```

Antes do primeiro acesso, confirme a fingerprint do servidor remoto por um canal confiável e registre a chave em `known_hosts`. Depois teste a conexão:

```bash
sudo -u backup ssh backup@backup.example.com 'echo connection-ok'
```

Por padrão, o projeto usa `StrictHostKeyChecking=yes`, evitando aceitar silenciosamente um host desconhecido. Consulte [docs/SECURITY.md](docs/SECURITY.md).

## Uso

### Validar o ambiente

```bash
sudo cloud-backup-validate all
```

### Informix

```bash
sudo cloud-backup-informix
```

### PostgreSQL

```bash
sudo cloud-backup-postgres
```

## Qualidade do código

Antes de publicar alterações, execute:

```bash
./tests/smoke.sh
```

O workflow `.github/workflows/shellcheck.yml` executa validação de sintaxe, ShellCheck e um scan preventivo para evitar que IPs literais, senhas atribuídas ou chaves privadas sejam publicados acidentalmente.

## Agendamento

Exemplo de `cron`:

```cron
00 22 * * * root /usr/local/sbin/cloud-backup-informix
00 01 * * * root /usr/local/sbin/cloud-backup-postgres
```

Instalação do exemplo:

```bash
sudo cp cron/backup.cron.example /etc/cron.d/cloud-backup
sudo chmod 0644 /etc/cron.d/cloud-backup
```

## Logs

```text
/var/log/cloud-backup/informix.log
/var/log/cloud-backup/postgres.log
/var/log/cloud-backup/upload.log
```

Exemplo esperado:

```text
2026-08-07 01:00:00 [INFO] Iniciando rotina PostgreSQL
2026-08-07 01:00:08 [INFO] Enviando arquivo de backup
2026-08-07 01:01:14 [INFO] Arquivo validado no servidor remoto
2026-08-07 01:01:14 [INFO] Rotina PostgreSQL concluída
```

## Segurança

Este repositório público foi projetado para **não versionar informações de produção**.

Não publique:

- senhas;
- chaves SSH privadas;
- arquivos `.env` reais;
- IPs internos ou externos de produção;
- nomes de clientes;
- dumps de banco;
- logs reais que revelem infraestrutura.

Leia [docs/SECURITY.md](docs/SECURITY.md).

## Documentação

- [Instalação](docs/INSTALLATION.md)
- [Arquitetura](docs/ARCHITECTURE.md)
- [Informix](docs/INFORMIX.md)
- [PostgreSQL](docs/POSTGRESQL.md)
- [Segurança](docs/SECURITY.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Testes de restauração](docs/RESTORE-TESTING.md)

## Autoria

**Matheus Barcelli** é o autor da documentação operacional que deu origem a este projeto e responsável pela concepção do fluxo apresentado neste repositório.

Veja também [AUTHORS.md](AUTHORS.md), [NOTICE](NOTICE) e [LICENSE](LICENSE).

Copyright © 2026 Matheus Barcelli. Distribuído sob a licença MIT.

## Roadmap

Melhorias que podem ser adicionadas futuramente:

- relatório resumido de execução;
- notificações de sucesso/falha;
- métricas para Zabbix/Prometheus;
- timers `systemd` como alternativa ao cron;
- testes automatizados com ShellCheck;
- ambiente de laboratório com containers;
- política de retenção diária/semanal/mensal.
