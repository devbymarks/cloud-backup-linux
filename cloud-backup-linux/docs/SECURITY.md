# Segurança

## Não armazene senha no Git

A documentação original continha uma senha em texto aberto. Ela não foi incluída neste projeto.

Troque imediatamente qualquer senha que já tenha sido compartilhada em mensagens, chamados ou documentação pública.

## Não copie chave privada sem necessidade

Em vez de puxar toda a pasta `.ssh` do servidor da nuvem para o cliente, prefira:

1. Gerar uma chave no cliente.
2. Enviar apenas a chave pública ao servidor.
3. Restringir a chave no `authorized_keys` quando possível.

## Permissões

Evite `chmod 777`. Sugestão:

```text
/home/backup/.ssh       0700
chave privada           0600
arquivos de configuração 0640
diretórios de backup    0770
scripts executáveis     0755
arquivos de backup      0640
```

## Host key

O projeto usa `StrictHostKeyChecking=yes` por padrão. Antes da primeira conexão, obtenha a chave pública do host remoto e **confirme a fingerprint por um canal confiável** antes de registrá-la em `known_hosts`.

Exemplo de coleta da chave, somente após validar a origem do host:

```bash
sudo -u backup ssh-keyscan -p 22 backup.example.com >> /home/backup/.ssh/known_hosts
```

Não desabilite a validação de host apenas para contornar erros de conexão.

## Proteção adicional

- Restrinja o usuário remoto somente ao diretório de backup.
- Use firewall para permitir SSH apenas dos IPs dos clientes.
- Implemente retenção e cópias imutáveis no servidor remoto.
- Monitore falhas do cron.
- Teste restauração periodicamente.

## Verificação de host SSH

A configuração pública usa `SSH_STRICT_HOST_KEY_CHECKING="yes"`. Antes da primeira conexão, valide a fingerprint do servidor remoto por um canal confiável e registre a chave no arquivo `known_hosts` do usuário de backup.

Evite desabilitar `StrictHostKeyChecking` em produção.

## Integridade do arquivo transferido

Quando `VERIFY_REMOTE_CHECKSUM="yes"`, o projeto calcula o SHA-256 do arquivo local e compara com o SHA-256 calculado no servidor remoto. A rotina falha se os valores forem diferentes.

O servidor remoto precisa disponibilizar o comando `sha256sum` para essa validação.

## Scan preventivo do repositório público

O teste `tests/security-scan.sh` procura padrões comuns de publicação acidental de dados sensíveis, incluindo:

- chaves privadas SSH;
- atribuições explícitas de senha;
- endereços IPv4 literais.

Esse teste é uma barreira adicional e não substitui revisão humana, secret scanning do GitHub nem gestão adequada de segredos.
