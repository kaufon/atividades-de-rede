#!/bin/bash

# EXERCICIO 8: Filtrar mensagens de erro, falha ou aviso do kernel
# Objetivo: exibir mensagens relacionadas a 'error', 'fail', 'warn' e termos semelhantes
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
    echo "Nenhum log do kernel foi encontrado"
    exit 1
fi

echo "=== ERROS E AVISOS DO KERNEL ==="
echo "Arquivo de log utilizado: $LOG_FILE"
echo

# Comando explicado:
# grep -Ei: busca padroes sem diferenciar maiusculas/minusculas
#   - kernel: garante foco em mensagens do kernel quando o log for syslog/messages
#   - error|fail|warn|panic|critical|segfault: palavras-chave pedidas e correlatas

grep -Ei '(kernel:|kernel\]|kernel)(.*(error|fail|warn|panic|critical|segfault)|.*(I/O error|BUG:|Oops:))|(error|fail|warn|panic|critical|segfault)' "$LOG_FILE" | \
    grep -Ei 'kernel:|kernel\]|kernel|BUG:|Oops:'

echo
echo "Nota: em sistemas sem kern.log, o kernel costuma registrar eventos em syslog ou messages."