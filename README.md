# Cloud Backup Linux

## Sobre o projeto

O **Cloud Backup Linux** é um projeto criado para automatizar o processo de backup de bancos de dados em servidores Linux e enviar esses arquivos com segurança para um servidor remoto.

A ideia surgiu a partir de uma necessidade real de infraestrutura: reduzir tarefas manuais, padronizar o processo de backup e diminuir o risco de falhas humanas.

O projeto foi desenvolvido e documentado por **Matheus Barcelli**.

---

## O que esse projeto faz?

De forma simples, o sistema executa quatro etapas:

1. Gera uma cópia de segurança do banco de dados.
2. Organiza os arquivos de backup.
3. Envia os arquivos para outro servidor através de uma conexão segura.
4. Registra informações da execução para facilitar validações e troubleshooting.

O projeto possui suporte para ambientes com:

* PostgreSQL
* Informix
* Linux
* SSH
* Rsync
* Shell Script
* Cron

---

## Por que esse projeto é importante?

Em empresas, bancos de dados armazenam informações essenciais para a operação.

Caso um servidor tenha uma falha, arquivos sejam corrompidos ou dados sejam perdidos, um backup confiável pode ser utilizado para recuperar o ambiente.

O objetivo deste projeto é tornar esse processo mais automatizado e organizado.

Em vez de depender de uma pessoa realizando os mesmos comandos manualmente todos os dias, o servidor pode executar as rotinas automaticamente nos horários configurados.

---

## Exemplo simples

Imagine uma empresa que possui um banco de dados em um servidor.

Sem automação, um profissional poderia precisar:

* acessar o servidor;
* gerar o backup;
* localizar o arquivo;
* conectar em outro servidor;
* copiar o backup;
* verificar se a transferência funcionou.

Com este projeto, essas etapas podem ser executadas automaticamente.

O fluxo é aproximadamente:

```text
Banco de Dados
      |
      v
Geração do Backup
      |
      v
Arquivo de Backup
      |
      v
Transferência Segura
      |
      v
Servidor de Backup
```

---

## Tecnologias utilizadas

### Linux

O projeto foi desenvolvido para ambientes Linux, sistema operacional muito utilizado em servidores e infraestrutura corporativa.

### Bash / Shell Script

Os scripts automatizam tarefas que normalmente seriam realizadas manualmente por um administrador de sistemas.

### PostgreSQL

Banco de dados amplamente utilizado em aplicações corporativas.

O projeto utiliza ferramentas do próprio PostgreSQL para gerar os backups.

### Informix

Também possui suporte para rotinas de backup em ambientes IBM Informix.

### SSH

O SSH permite que servidores se comuniquem de forma segura.

Neste projeto, ele é utilizado para autenticação entre o servidor que gera o backup e o servidor que irá armazená-lo.

### Rsync / SCP

Ferramentas utilizadas para transferir arquivos entre servidores Linux.

### Cron

O Cron permite programar tarefas automáticas.

Por exemplo:

```text
22:00 -> Backup Informix
01:00 -> Backup PostgreSQL
```

Assim, os backups podem ser realizados todos os dias sem intervenção manual.

---

## Segurança

Por se tratar de um projeto público de portfólio, nenhuma informação real de ambiente corporativo foi publicada.

O repositório não contém:

* senhas reais;
* IPs reais;
* nomes de clientes;
* chaves SSH privadas;
* credenciais de produção;
* caminhos específicos de empresas.

As configurações sensíveis são tratadas através de arquivos de exemplo e variáveis.

---

## Validação dos backups

Além de gerar e transferir os arquivos, o projeto possui recursos para ajudar a verificar se o processo ocorreu corretamente.

Entre eles:

* logs de execução;
* validação de conexão;
* verificação dos arquivos;
* checksum SHA-256;
* prevenção de execuções duplicadas.

O checksum funciona como uma espécie de "impressão digital" do arquivo.

Ele ajuda a confirmar que o backup enviado para outro servidor é igual ao arquivo original.

---

## Estrutura do projeto

```text
cloud-backup-linux/
│
├── README.md
├── LICENSE
├── NOTICE
├── AUTHORS.md
├── CHANGELOG.md
│
├── config/
│   └── backup.env.example
│
├── docs/
│   ├── architecture.md
│   ├── installation.md
│   ├── security.md
│   ├── restore-testing.md
│   └── troubleshooting.md
│
├── scripts/
│   ├── install.sh
│   ├── validate.sh
│   ├── upload.sh
│   │
│   ├── informix/
│   └── postgres/
│
├── cron/
│
└── .github/
    └── workflows/
```

A separação por diretórios facilita a manutenção e permite que outras pessoas entendam rapidamente onde estão os scripts, configurações e documentação.

---

## O que este projeto demonstra

Este projeto foi criado para demonstrar conhecimentos práticos relacionados a infraestrutura e administração de servidores.

Entre as competências aplicadas estão:

* Administração Linux
* Automação de tarefas
* Shell Script
* Backup de banco de dados
* PostgreSQL
* Informix
* SSH
* Rsync
* Segurança básica de infraestrutura
* Troubleshooting
* Documentação técnica
* Git e GitHub
* GitHub Actions
* Boas práticas de organização de projetos

---

## Cenário de uso

Um possível cenário seria:

```text
Servidor da Aplicação
        |
        |
Servidor de Banco de Dados
        |
        | gera backup
        v
Diretório Local de Backup
        |
        | SSH / Rsync
        v
Servidor Remoto de Backup
```

Caso ocorra um problema no servidor principal, os arquivos armazenados no servidor remoto podem fazer parte do processo de recuperação.

---

## Motivação

Este projeto nasceu a partir de uma documentação operacional criada para configurar rotinas de backup em servidores Linux.

A documentação foi posteriormente organizada e transformada em um projeto de portfólio, com foco em:

* automação;
* segurança;
* padronização;
* documentação;
* facilidade de manutenção.

---

## Objetivo profissional

O objetivo deste repositório é demonstrar experiência prática com atividades comuns em ambientes de infraestrutura, Cloud, DevOps e administração de sistemas.

O projeto procura mostrar não apenas a execução de comandos Linux, mas também a capacidade de transformar uma rotina operacional em uma solução organizada, documentada e reutilizável.

---

## Autor

**Matheus Barcelli**

Projeto, documentação e implementação desenvolvidos como parte de portfólio profissional na área de tecnologia e infraestrutura.

Copyright © 2026 Matheus Barcelli.
