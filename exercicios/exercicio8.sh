#!/bin/bash

# ==============================================================================
# EXERCÍCIO 8: Erros e Falhas do Kernel
# Objetivo: Filtrar e exibir mensagens relacionadas a erros ou falhas do kernel
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "kern.log" -o -name "syslog" -o -name "messages" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log do kernel ausente ou sem permissão." >&2 && exit 1

echo "=== 🚨 ALERTAS E FALHAS DO KERNEL ==="

awk '
    BEGIN { IGNORECASE = 1 }
    /(kernel(:|\])?|vmlinuz)/ && /(error|fail|warn|panic|critical|segfault|bug|oops)/ {
        $1 = "🕒 " $1
        print $0
    }
' "$LOG_ALVO"

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio8.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio8.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio8.sh
# 4. Injete dados falsos simulando erros do kernel no seu log para o teste:
#    sudo bash -c 'echo "Mar 13 10:15:22 wsl kernel: [    2.345123] ata1.00: failed command: READ FPDMA QUEUED" >> /var/log/kern.log'
#    sudo bash -c 'echo "Mar 13 10:20:05 wsl kernel: [   14.002931] WARNING: CPU: 0 PID: 123 at fs/ext4/inode.c" >> /var/log/kern.log'
#    sudo bash -c 'echo "Mar 13 10:25:50 wsl kernel: [   55.992120] Out of memory: Killed process 999 (apache2) total-vm:4096kB" >> /var/log/kern.log'
#    sudo bash -c 'echo "Mar 13 10:30:11 wsl kernel: [   80.111222] EXT4-fs (sda1): error count since last fsck: 2" >> /var/log/kern.log'
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio8.sh
# ==============================================================================
