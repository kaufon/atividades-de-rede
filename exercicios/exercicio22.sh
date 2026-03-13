#!/bin/bash

# EXERCICIO 22: Encontrar eventos de 'segfault' ou 'killed' no log do sistema
# Objetivo: listar erros graves de processos encerrados abruptamente
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

echo "=== EVENTOS DE SEGFAULT OU PROCESSO KILLED ==="
echo "Arquivo de log utilizado: $LOG_FILE"
echo

# Comando explicado:
# grep -Ei: procura mensagens comuns de encerramento grave de processo

grep -Ei 'segfault|killed process|killed|oom-killer|out of memory' "$LOG_FILE"

echo
echo "Nota: mensagens de OOM Killer tambem foram incluidas por indicarem terminacao forcada de processo."