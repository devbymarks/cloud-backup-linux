# ☁️ Cloud Backup Linux

> Automação de backup para ambientes Linux com envio seguro para um servidor remoto utilizando **Bash, SSH e Rsync**.

[![Shell Script](https://img.shields.io/badge/Shell-Bash-121011?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/OS-Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![Rsync](https://img.shields.io/badge/Transfer-Rsync-2E8B57)](https://rsync.samba.org/)
[![SSH](https://img.shields.io/badge/Security-SSH-222222?logo=openssh&logoColor=white)](https://www.openssh.com/)

## 📌 Sobre o projeto

O **Cloud Backup Linux** é um conjunto de scripts Bash desenvolvido para automatizar o envio de backups de servidores Linux para um servidor remoto.

O projeto foi pensado para ambientes que utilizam **Informix e/ou PostgreSQL**, oferecendo rotinas independentes para diferentes cenários:

- backup somente Informix;
- backup Informix + PostgreSQL;
- backup somente PostgreSQL.

Além do envio, o projeto possui validação do arquivo transferido e política de retenção para evitar o acúmulo de backups antigos.

> **Importante:** este repositório não contém dados reais de clientes, endereços IP de produção, credenciais, chaves SSH ou informações sensíveis. Todas as configurações são exemplos genéricos.

---

## 🎯 Objetivos

O projeto busca:

- automatizar o envio de backups;
- reduzir tarefas manuais de administração;
- utilizar SSH para comunicação segura;
- utilizar Rsync para transferência eficiente;
- validar o backup após a transferência;
- evitar exclusão prematura de backups;
- controlar a retenção de arquivos antigos;
- centralizar funções comuns em uma biblioteca Bash;
- facilitar a implantação em diferentes servidores e clientes.

---

## 🏗️ Arquitetura

```text
Servidor Linux
│
├── /opt/backup
│   ├── server-bd_0_L0*
│   ├── bkp_logus*
│   ├── database
│   ├── sqlhosts
│   └── onconfig.ol_matriz
│
│
└── Cloud Backup
        │
        │ SSH + Rsync
        ▼
Servidor de Backup
│
└── /backup/clientes/<cliente>
    ├── backup Informix
    ├── backup PostgreSQL
    ├── database
    ├── sqlhosts
    └── onconfig.ol_matriz
```

---

## 📂 Estrutura do projeto

```text
cloud-backup-linux/
│
├── config/
│   └── backup.env.example
│
├── cron/
│   └── backup.cron.example
│
├── docs/
│   └── BACKUP-ROUTINES.md
│
├── scripts/
│   ├── backup/
│   │   ├── backup-informix.sh
│   │   ├── backup-informix-postgres.sh
│   │   └── backup-postgres.sh
│   │
│   └── lib/
│       └── common.sh
│
├── README.md
└── LICENSE
```

---

## ⚙️ Rotinas disponíveis

### 🔵 Somente Informix

```bash
backup-informix.sh
```

Responsável por:

- localizar o backup Informix mais recente;
- transferir o arquivo para o servidor remoto;
- transferir arquivos auxiliares;
- validar a transferência;
- remover versões antigas conforme a política de retenção.

Arquivos auxiliares utilizados como exemplo:

```text
database
sqlhosts
onconfig.ol_matriz
```

---

### 🟢 Informix + PostgreSQL

```bash
backup-informix-postgres.sh
```

Executa o fluxo para os dois bancos:

```text
Informix
   +
PostgreSQL
```

Os backups são enviados e validados individualmente antes da limpeza das versões antigas.

---

### 🟠 Somente PostgreSQL

```bash
backup-postgres.sh
```

Responsável por:

- localizar o backup PostgreSQL mais recente;
- transferir o arquivo;
- validar a transferência;
- aplicar a política de retenção.

---

## 🔐 Validação do backup

Uma das principais características do projeto é que a limpeza dos arquivos antigos **não ocorre imediatamente após o `rsync`**.

O fluxo é:

```text
Localiza backup
      │
      ▼
Transfere com Rsync
      │
      ▼
Confere tamanho
      │
      ▼
Confere SHA-256
      │
      ▼
Backup validado
      │
      ▼
Remove versões antigas
```

Isso reduz o risco de perder a última cópia válida caso uma transferência apresente problema.

---

## 🔄 Rsync

A transferência utiliza:

```bash
rsync -az -e ssh
```

Benefícios:

- transferência incremental;
- compressão durante o envio;
- preservação de dados;
- utilização do SSH;
- bom desempenho para arquivos grandes.

---

## 🔑 SSH

A comunicação com o servidor remoto utiliza SSH.

Recomenda-se configurar autenticação por chave:

```text
Servidor de origem
        │
        │ SSH
        ▼
Servidor de backup
```

O projeto não armazena senhas ou chaves privadas no repositório.

---

## 🗂️ Configuração

A configuração deve ser feita fora do código-fonte.

Utilize como base:

```text
config/backup.env.example
```

Exemplo:

```bash
CLOUD_HOST="backup.example.com"
CLOUD_PORT="22"
CLOUD_USER="backup"

CLOUD_BASE_DIR="/backup/clientes"
CLOUD_CLIENT_DIR="cliente_exemplo"

BACKUP_ROOT="/opt/backup"

INFORMIX_BACKUP_PATTERN="server-bd_0_L0*"
POSTGRES_BACKUP_PATTERN="bkp_logus*"

VERIFY_REMOTE_CHECKSUM="yes"
```

### ⚠️ Nunca publique

Não coloque no Git:

```text
❌ senhas
❌ chaves privadas SSH
❌ IPs de produção
❌ domínios internos
❌ nomes reais de clientes
❌ arquivos de backup
❌ arquivos de configuração de produção
❌ tokens
❌ credenciais
```

---

## ⏰ Agendamento com Cron

As rotinas podem ser executadas automaticamente pelo `cron`.

Exemplo:

```cron
00 22 * * * root /opt/cloud-backup/scripts/backup/backup-informix.sh
```

Ou:

```cron
00 01 * * * root /opt/cloud-backup/scripts/backup/backup-postgres.sh
```

O arquivo:

```text
cron/backup.cron.example
```

contém exemplos de agendamento.

---

## 🧹 Política de retenção

Depois que o novo backup é transferido e validado, o projeto pode remover versões antigas.

Exemplo:

```text
Servidor remoto

backup_01
backup_02
backup_03  ← novo backup validado

        ↓

backup_03  ← mantido
```

A retenção pode ser ajustada de acordo com a necessidade do ambiente.

---

## 🛡️ Tratamento de erros

Os scripts utilizam:

```bash
set -Eeuo pipefail
```

Isso ajuda a identificar situações como:

- variável inexistente;
- comando com erro;
- arquivo não encontrado;
- falha no SSH;
- falha no Rsync;
- erro na validação;
- falha na comunicação com o servidor remoto.

---

## 🧰 Tecnologias utilizadas

| Tecnologia | Utilização |
|---|---|
| Bash | Automação |
| Linux | Sistema operacional |
| SSH | Comunicação segura |
| Rsync | Transferência |
| SHA-256 | Validação |
| Cron | Agendamento |
| Informix | Banco de dados |
| PostgreSQL | Banco de dados |

---

## 🚀 Instalação

Clone o projeto:

```bash
git clone https://github.com/SEU-USUARIO/cloud-backup-linux.git
cd cloud-backup-linux
```

Copie o exemplo de configuração:

```bash
sudo mkdir -p /etc/cloud-backup
sudo cp config/backup.env.example /etc/cloud-backup/backup.env
```

Edite:

```bash
sudo nano /etc/cloud-backup/backup.env
```

Configure as informações do seu ambiente.

Depois, dê permissão de execução:

```bash
sudo chmod +x scripts/backup/*.sh
sudo chmod +x scripts/lib/common.sh
```

---

## 🧪 Teste

Antes de colocar no `cron`, execute manualmente:

```bash
sudo /opt/cloud-backup/scripts/backup/backup-informix.sh
```

Para Informix + PostgreSQL:

```bash
sudo /opt/cloud-backup/scripts/backup/backup-informix-postgres.sh
```

Para PostgreSQL:

```bash
sudo /opt/cloud-backup/scripts/backup/backup-postgres.sh
```

---

## 📋 Boas práticas

Para ambientes de produção:

1. utilizar autenticação SSH por chave;
2. manter `StrictHostKeyChecking` habilitado;
3. não armazenar credenciais no Git;
4. testar restauração periodicamente;
5. monitorar espaço em disco;
6. manter logs das execuções;
7. validar os backups antes da retenção;
8. manter mais de uma cópia quando a política de recuperação exigir;
9. testar os scripts antes de adicioná-los ao `cron`.

---

## 📈 Possíveis evoluções

O projeto pode evoluir para incluir:

- monitoramento centralizado;
- alertas por e-mail;
- integração com Telegram ou WhatsApp;
- dashboard de backups;
- retenção por quantidade de dias;
- retenção diária/semanal/mensal;
- logs centralizados;
- relatório de sucesso e falha;
- monitoramento de espaço em disco;
- verificação automática de restauração.

---

## 👨‍💻 Autor

**Matheus Barcelli**

Projeto desenvolvido como parte de estudos e práticas de **Linux, Bash, Infraestrutura, Banco de Dados e Automação**.

---

## ⭐ Contribuição

Sugestões, melhorias e contribuições são bem-vindas.

Se você encontrar algum problema ou tiver uma ideia para melhorar o projeto, abra uma **Issue** ou envie um **Pull Request**.

---

## ⭐ Apoie o projeto

Se este projeto foi útil para você, considere deixar uma ⭐ no repositório.

---

## 📄 Licença

Este projeto está disponível sob a licença definida no arquivo:

```text
LICENSE
```
