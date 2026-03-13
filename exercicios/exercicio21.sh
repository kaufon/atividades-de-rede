#!/bin/bash

# EXERCICIO 21: Buscar mensagens de erro ou aviso de um servico especifico
# Objetivo: localizar eventos de erro/warning gerados por um servico em execucao
# Uso: ./exercicio21_erros_servico.sh [nome_do_servico]

SERVICO="${1:-sshd}"
LOG_FILES=("/var/log/auth.log" "/var/log/syslog" "/var/log/messages")
ENCONTROU_LOG=0
ENCONTROU_EVENTO=0

echo "=== ERROS E AVISOS DO SERVICO $SERVICO ==="
echo

# Comando explicado:
# percorremos os logs mais provaveis e usamos grep -Ei para localizar o servico
# combinado com palavras-chave tipicas de erro e alerta

for file in "${LOG_FILES[@]}"; do
    if [ -f "$file" ]; then
        ENCONTROU_LOG=1
        RESULTADO=$(grep -Ei "$SERVICO.*(error|warning|warn|fail|failed)|((error|warning|warn|fail|failed).*$SERVICO)" "$file")

        if [ -n "$RESULTADO" ]; then
            ENCONTROU_EVENTO=1
            echo "Arquivo de log utilizado: $file"
            echo "$RESULTADO"
            echo
        fi
    fi
done

if [ "$ENCONTROU_LOG" -eq 0 ]; then
    echo "Nenhum log padrao foi encontrado no sistema"
    exit 1
fi

if [ "$ENCONTROU_EVENTO" -eq 0 ]; then
    echo "Nenhum erro ou aviso foi encontrado para o servico '$SERVICO' nos logs analisados"
fi