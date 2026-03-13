#!/bin/bash

# EXERCICIO 20: Identificar pacotes atualizados no sistema
# Objetivo: mostrar o nome do pacote e a data da atualizacao
# Arquivos de log utilizados: /var/log/dpkg.log, /var/log/dnf.log ou /var/log/yum.log

LOG_FILES=("/var/log/dpkg.log" "/var/log/dnf.log" "/var/log/yum.log")
LOG_FILE=""

for file in "${LOG_FILES[@]}"; do
    if [ -f "$file" ]; then
        LOG_FILE="$file"
        break
    fi
done

if [ -z "$LOG_FILE" ]; then
    echo "Nenhum log de gerenciador de pacotes foi encontrado"
    exit 1
fi

echo "=== PACOTES ATUALIZADOS NO SISTEMA ==="
echo "Arquivo de log utilizado: $LOG_FILE"
echo

if [ "$LOG_FILE" = "/var/log/dpkg.log" ]; then
    awk '$3 == "upgrade" {
        printf "Data/Hora: %-19s | Pacote: %-35s | De: %-15s | Para: %s\n", $1 " " $2, $4, $5, $6
    }' "$LOG_FILE"
else
    awk '/Updated:/ {
        pacote = substr($0, index($0, "Updated:") + 9)
        printf "Data/Hora: %-19s | Pacote: %s\n", $1 " " $2 " " $3, pacote
    }' "$LOG_FILE"
fi

echo
echo "Nota: no dpkg.log, as versoes antiga e nova aparecem explicitamente na mesma linha."