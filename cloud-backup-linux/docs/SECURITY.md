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

O projeto usa `StrictHostKeyChecking=accept-new`. Em ambientes críticos, registre previamente a chave do host:

```bash
sudo -u backup ssh-keyscan -p 22 HOST_DA_NUVEM >> /home/backup/.ssh/known_hosts
```

Depois altere o script para `StrictHostKeyChecking=yes`.

## Proteção adicional

- Restrinja o usuário remoto somente ao diretório de backup.
- Use firewall para permitir SSH apenas dos IPs dos clientes.
- Implemente retenção e cópias imutáveis no servidor remoto.
- Monitore falhas do cron.
- Teste restauração periodicamente.
