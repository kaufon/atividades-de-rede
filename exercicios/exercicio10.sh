#!/bin/bash

# EXERCICIO 10: Encontrar mensagens de problemas com dispositivos de hardware
# Objetivo: localizar erros relacionados a disco, USB, NVMe, SCSI, SATA e afins
# Arquivos de log utilizados: /var/log/kern.log, /var/log/messages ou /var/log/syslog

LOG_FILES=("/var/log/kern.log" "/var/log/messages" "/var/log/syslog")
LOG_FILE=""

for file in "${LOG_FILES[@]}"; do
    if [ -f "$file" ]; then
        LOG_FILE="$file"
        break
    fi
done

if [ -z "$LOG_FILE" ]; then
    echo "Nenhum log de hardware foi encontrado"
    exit 1
fi

echo "=== PROBLEMAS COM DISPOSITIVOS DE HARDWARE ==="
echo "Arquivo de log utilizado: $LOG_FILE"
echo

# Comando explicado:
# grep -Ei: busca termos frequentes de falha em hardware
#   - disk|ata|scsi|nvme|usb: tipos de dispositivo
#   - error|fail|reset|timeout|I/O error: sintomas de problema

grep -Ei '(disk|ata|scsi|nvme|usb|sata|blk_update_request|sd[a-z])' "$LOG_FILE" | \
    grep -Ei '(error|fail|reset|timeout|I/O error|offline|fault|denied|abort|critical)'

echo
echo "Nota: para diagnostico mais profundo, vale complementar com 'dmesg' ou logs do journal."