# Changelog

## 2.0.0 — 2026-08-07

- Autoria e copyright atribuídos a Matheus Barcelli.
- README revisado para apresentação de portfólio.
- Sanitização de IPs, senhas e nomes de clientes reais.
- Verificação de integridade SHA-256 após upload.
- SSH com verificação estrita de host configurável.
- Scan preventivo de dados sensíveis no CI.
- GitHub Actions com smoke test e ShellCheck.
- Adicionados `AUTHORS.md`, `CITATION.cff` e `.editorconfig`.
- Configuração do padrão de arquivos de backup Informix tornou-se ajustável.

## 1.0.0

- Estrutura inicial do projeto.
- Suporte a backups Informix e PostgreSQL.
- Upload por rsync/scp sobre SSH.
- Logs, locks, retenção local e validação de ambiente.
