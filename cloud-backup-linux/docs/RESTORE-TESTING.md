# Testes de restauração

Um backup só deve ser considerado confiável quando a restauração também é testada.

Este documento descreve verificações seguras para validar os artefatos gerados pelo projeto sem restaurar diretamente sobre um ambiente de produção.

## PostgreSQL

### Backup no formato custom

Liste o conteúdo do dump:

```bash
pg_restore --list arquivo.dump
```

O comando deve finalizar sem erro e apresentar os objetos existentes no backup.

Para um teste completo, restaure em uma instância PostgreSQL isolada:

```bash
createdb restore_test
pg_restore --clean --if-exists --no-owner --dbname=restore_test arquivo.dump
```

Depois valide tabelas, registros esperados e logs da restauração.

### Backup SQL compactado

Valide primeiro o arquivo gzip:

```bash
gzip -t arquivo.sql.gz
```

Em laboratório, restaure em um banco descartável:

```bash
gunzip -c arquivo.sql.gz | psql --dbname=restore_test
```

## Informix

A restauração com `ontape` deve ser executada apenas em um ambiente isolado e compatível com a versão e a configuração do servidor de origem.

Antes do teste:

1. valide a existência do arquivo de backup e dos arquivos `onconfig`, `sqlhosts` e `database.txt`;
2. confirme a versão do Informix usada para gerar o backup;
3. prepare um servidor de laboratório separado da produção;
4. revise `TAPEDEV`, `TAPEBLK`, `TAPESIZE` e parâmetros de memória;
5. siga o procedimento oficial de restauração aplicável à versão instalada.

> Nunca execute um procedimento de restore destrutivo diretamente em produção apenas para testar o backup.

## Frequência recomendada

Para ambientes críticos, mantenha uma rotina periódica de restore drill e registre:

- data do teste;
- arquivo utilizado;
- checksum;
- duração;
- resultado;
- responsável;
- problemas encontrados;
- ações corretivas.

## Critério de sucesso

O processo de backup deve ser considerado saudável somente quando:

- a criação do arquivo termina sem erro;
- o upload é concluído;
- o checksum local e remoto coincide;
- o artefato pode ser lido pelas ferramentas do banco;
- uma restauração em laboratório é concluída periodicamente.
