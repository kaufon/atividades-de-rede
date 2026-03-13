#!/bin/bash

# EXERCICIO 6: Mostrar a data e a hora do ultimo boot do sistema
# Objetivo: identificar quando o sistema foi inicializado pela ultima vez
# Arquivo de log utilizado: /var/log/wtmp

WTMP_FILE="/var/log/wtmp"

if [ ! -f "$WTMP_FILE" ]; then
    echo "Arquivo de log $WTMP_FILE nao encontrado"
    exit 1
fi

if ! command -v last >/dev/null 2>&1; then
    echo "Comando 'last' nao encontrado no sistema"
    exit 1
fi

echo "=== ULTIMO BOOT DO SISTEMA ==="
echo "Arquivo de log utilizado: $WTMP_FILE"
echo

# Comando explicado:
# last -x -f /var/log/wtmp: le eventos especiais de boot, shutdown e runlevel
# awk '/reboot/': mantem apenas eventos de inicializacao
# exit na primeira linha: 'last' ja retorna em ordem decrescente, entao a primeira
#                         ocorrencia de reboot representa o boot mais recente

last -x -f "$WTMP_FILE" | \
    awk '/reboot/ {
        printf "Ultimo boot: %s %s %s %s %s %s\n", $1, $4, $5, $6, $7, $8
        found = 1
        exit
    }
    END {
        if (!found) {
            print "Nenhum evento de boot foi encontrado no log"
        }
    }'

echo
echo "Nota: o comando consulta o arquivo wtmp, que registra eventos de login e boot."