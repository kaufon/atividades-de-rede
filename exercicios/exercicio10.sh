#!/bin/bash

# ==============================================================================
# EXERCÍCIO 10: Problemas com dispositivos de hardware
# Objetivo: Buscar mensagens de log que indiquem problemas em dispositivos
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "kern.log" -o -name "syslog" -o -name "messages" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log não encontrado ou sem permissão." >&2 && exit 1

echo "=== 🛠️ AUDITORIA DE HARDWARE (ERROS E FALHAS) ==="

awk '
    BEGIN { IGNORECASE = 1 }
    /(disk|ata[0-9]+|scsi|nvme|usb|sata|blk_update_request|sd[a-z])/ && /(error|fail|reset|timeout|i\/o error|offline|fault|denied|abort|critical)/ {
        data_hora = $1 " " $2 " " $3
        
        mensagem = $0
        sub(/^([^ ]+ +){3}/, "", mensagem)
        
        printf "📅 %-16s | ⚠️  %s\n", data_hora, mensagem
    }
' "$LOG_ALVO"

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio10.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio10.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio10.sh
# 4. Injete dados falsos simulando falhas físicas de hardware no seu log:
#    sudo bash -c 'echo "Mar 13 08:00:10 wsl kernel: [  123.456] usb 1-1: device descriptor read/64, error -110" >> /var/log/kern.log'
#    sudo bash -c 'echo "Mar 13 08:05:22 wsl kernel: [  234.567] blk_update_request: I/O error, dev sda, sector 2048" >> /var/log/kern.log'
#    sudo bash -c 'echo "Mar 13 08:10:45 wsl kernel: [  345.678] nvme nvme0: controller is down; will reset: CSTS=0xffffffff" >> /var/log/kern.log'
#    sudo bash -c 'echo "Mar 13 08:15:30 wsl kernel: [  456.789] ata3.00: failed command: READ FPDMA QUEUED" >> /var/log/kern.log'
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio10.sh
# ==============================================================================
