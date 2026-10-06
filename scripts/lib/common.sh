#!/usr/bin/env bash
set -Eeuo pipefail

CONFIG_FILE="${CONFIG_FILE:-/etc/cloud-backup/backup.env}"

log() {
    local level="$1"; shift
    printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*"
}

die() {
    log ERROR "$*"
    exit 1
}

load_config() {
    [[ -r "$CONFIG_FILE" ]] || die "Configuração não encontrada: $CONFIG_FILE"
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"

    : "${CLOUD_HOST:?CLOUD_HOST não definido}"
    : "${CLOUD_USER:?CLOUD_USER não definido}"
    : "${CLOUD_CLIENT_DIR:?CLOUD_CLIENT_DIR não definido}"
    : "${CLOUD_BASE_DIR:?CLOUD_BASE_DIR não definido}"
    : "${BACKUP_ROOT:=/opt/backup}"
    : "${CLOUD_PORT:=22}"
    : "${SSH_CONNECT_TIMEOUT:=20}"
    : "${SSH_STRICT_HOST_KEY_CHECKING:=yes}"
    : "${SSH_KNOWN_HOSTS_FILE:=/home/backup/.ssh/known_hosts}"
    : "${BACKUP_USER:=backup}"
    : "${BACKUP_GROUP:=backup}"
    : "${VERIFY_REMOTE_CHECKSUM:=yes}"
}

require_commands() {
    local cmd
    for cmd in "$@"; do
        command -v "$cmd" >/dev/null 2>&1 || die "Comando não encontrado: $cmd"
    done
}

remote_dir() {
    printf '%s/%s' "${CLOUD_BASE_DIR%/}" "${CLOUD_CLIENT_DIR#/}"
}

ssh_exec() {
    ssh \
        -p "$CLOUD_PORT" \
        -o BatchMode=yes \
        -o "ConnectTimeout=$SSH_CONNECT_TIMEOUT" \
        -o "StrictHostKeyChecking=$SSH_STRICT_HOST_KEY_CHECKING" \
        -o "UserKnownHostsFile=$SSH_KNOWN_HOSTS_FILE" \
        "$CLOUD_USER@$CLOUD_HOST" "$@"
}

rsync_file() {
    local file="$1"
    rsync -az \
        -e "ssh -p $CLOUD_PORT -o BatchMode=yes -o ConnectTimeout=$SSH_CONNECT_TIMEOUT -o StrictHostKeyChecking=$SSH_STRICT_HOST_KEY_CHECKING -o UserKnownHostsFile=$SSH_KNOWN_HOSTS_FILE" \
        -- "$file" "$CLOUD_USER@$CLOUD_HOST:$(remote_dir)/"
}

verify_remote_file() {
    local file="$1"
    local name
    name="$(basename "$file")"

    [[ -f "$file" ]] || die "Arquivo local não existe: $file"

    local_size="$(stat -c '%s' "$file")"
    remote_size="$(ssh_exec "stat -c '%s' '$(remote_dir)/$name'")"

    [[ "$local_size" == "$remote_size" ]] ||
        die "Tamanho diferente: $name (local=$local_size remoto=$remote_size)"

    if [[ "${VERIFY_REMOTE_CHECKSUM:-yes}" == "yes" ]]; then
        require_commands sha256sum
        local_sha="$(sha256sum "$file" | awk '{print $1}')"
        remote_sha="$(ssh_exec "sha256sum '$(remote_dir)/$name' | awk '{print \$1}'")"
        [[ "$local_sha" == "$remote_sha" ]] ||
            die "Checksum SHA-256 diferente: $name"
    fi

    log INFO "Arquivo validado no remoto: $name"
}

prepare_remote_dir() {
    ssh_exec "mkdir -p '$(remote_dir)' && test -w '$(remote_dir)'"
}

find_latest() {
    local pattern="$1"
    find "$BACKUP_ROOT" -maxdepth 1 -type f -name "$pattern" \
        -printf '%T@ %p\n' 2>/dev/null |
        sort -nr | head -1 | cut -d' ' -f2-
}

remove_old_remote_backups() {
    local pattern="$1"
    local keep="${2:-1}"

    # Só é chamado depois que o novo arquivo foi enviado e validado.
    ssh_exec "
        cd '$(remote_dir)' || exit 1
        files=\$(ls -1t $pattern 2>/dev/null || true)
        count=0
        for file in \$files; do
            count=\$((count + 1))
            if [ \$count -gt $keep ]; then
                rm -f -- \"\$file\"
            fi
        done
    "
}

send_and_verify() {
    local file="$1"
    [[ -f "$file" ]] || die "Arquivo não encontrado: $file"
    log INFO "Enviando $(basename "$file")"
    rsync_file "$file"
    verify_remote_file "$file"
}
