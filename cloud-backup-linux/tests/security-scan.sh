#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail=0

check_pattern() {
  local label="$1"
  local pattern="$2"
  if grep -RInE --exclude-dir=.git --exclude='security-scan.sh' "$pattern" . >/tmp/cloud-backup-security-scan.txt 2>/dev/null; then
    echo "[ERRO] Possível dado sensível encontrado: $label"
    cat /tmp/cloud-backup-security-scan.txt
    fail=1
  else
    echo "[OK] $label"
  fi
}

check_pattern "chave privada SSH" 'BEGIN (OPENSSH|RSA|EC|DSA) PRIVATE KEY'
check_pattern "senha atribuída em arquivo" '(^|[[:space:]])(PASSWORD|PASSWD|SENHA)[[:space:]]*=[[:space:]]*[^#[:space:]]+'
check_pattern "IPv4 literal" '(^|[^0-9])([0-9]{1,3}\.){3}[0-9]{1,3}([^0-9]|$)'

rm -f /tmp/cloud-backup-security-scan.txt

if (( fail > 0 )); then
  echo "Security scan falhou. Revise os itens acima antes de publicar."
  exit 1
fi

echo "Security scan concluído sem achados conhecidos."
