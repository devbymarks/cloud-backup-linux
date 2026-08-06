# Informix

## Ajustes no `onconfig`

Edite o arquivo correspondente ao ambiente, por exemplo:

```bash
vi /opt/IBM/informix/etc/onconfig.ol_matriz
```

Localize os parâmetros de fita e ajuste conforme a estrutura real:

```text
TAPEDEV /opt/backup/informix
TAPEBLK 1000
TAPESIZE 0
```

Para compactar o backup:

```text
BACKUP_FILTER '/usr/bin/gzip -c'
RESTORE_FILTER '/usr/bin/gzip -dc'
```

Parâmetros de memória mencionados na documentação original:

```text
RESIDENT 0
SHMBASE 0x44000000L
SHMVIRTSIZE 48656
SHMADD 16192
EXTSHMADD 8192
SHMTOTAL 0
SHMVIRT_ALLOCSEG 0,3
```

> Não altere memória compartilhada em produção sem validar compatibilidade, capacidade do servidor e orientação do administrador Informix.

## Execução

```bash
sudo cloud-backup-informix
```

O fluxo:

1. Executa `ontape -s -L 0` como usuário Informix.
2. Salva `onstat -d`.
3. Copia `onconfig` e `sqlhosts`.
4. Transfere os arquivos para a nuvem.
5. Confirma o tamanho remoto.
