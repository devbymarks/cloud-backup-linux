# Arquitetura

O projeto separa a geração do backup da etapa de transporte. Isso facilita manutenção, diagnóstico e reutilização.

```text
┌───────────────────────────────┐
│        Servidor Linux         │
│                               │
│  ┌──────────┐  ┌───────────┐  │
│  │ Informix │  │ PostgreSQL│  │
│  └────┬─────┘  └─────┬─────┘  │
│       │              │          │
│       └──────┬───────┘          │
│              ▼                  │
│      Geração do backup          │
│              │                  │
│      Validação + logs           │
│              │                  │
│              ▼                  │
│       rsync/scp sobre SSH       │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│      Servidor de Backup       │
│  diretório isolado por ambiente│
└───────────────────────────────┘
```

## Componentes

- `create-*-backup.sh`: executa a ferramenta nativa do banco e produz o artefato.
- `run-*-backup.sh`: orquestra lock, permissões, upload, retenção e logs.
- `upload-to-cloud.sh`: abstrai o transporte remoto.
- `validate-backup.sh`: verifica dependências locais e conectividade SSH.
- `common.sh`: concentra funções compartilhadas e carregamento da configuração.

## Decisões de projeto

1. **Configuração fora do código:** dados de ambiente ficam em `/etc/cloud-backup/backup.env`.
2. **Sem credenciais no Git:** autenticação remota deve utilizar chave SSH.
3. **Menor privilégio:** evita `chmod 777` e usa permissões mais restritas.
4. **Execução idempotente:** o instalador preserva configuração existente.
5. **Lock de execução:** impede duas rotinas do mesmo banco simultaneamente.
6. **Validação pós-upload:** opcionalmente compara o tamanho local e remoto.
