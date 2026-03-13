#!/bin/bash

# EXERCICIO 16: Listar mensagens contendo critical, fatal ou segfault
# Objetivo: localizar falhas criticas no log do sistema
# Arquivos de log utilizados: /var/log/syslog, /var/log/messages ou /var/log/kern.log

LOG_FILES=("/var/log/syslog" "/var/log/messages" "/var/log/kern.log")
LOG_FILE=""

for file in "${LOG_FILES[@]}"; do
    if [ -f "$file" ]; then
        LOG_FILE="$file"
        break
    fi
done

if [ -z "$LOG_FILE" ]; then
    echo "Nenhum log do sistema foi encontrado"
    exit 1
fi

echo "=== FALHAS CRITICAS E ERROS GRAVES ==="
echo "Arquivo de log utilizado: $LOG_FILE"
echo

# Comando explicado:
# grep -Ei: busca termos de falha grave sem diferenciar maiusculas/minusculas

grep -Ei 'critical|fatal|segfault' "$LOG_FILE"

echo
echo "Nota: se o sistema utilizar journalctl como fonte principal, alguns eventos podem nao estar em /var/log."