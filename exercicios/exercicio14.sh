#!/bin/bash

# EXERCICIO 14: Calcular o tempo de atividade entre um boot e o desligamento seguinte
# Objetivo: analisar o ultimo ciclo completo de boot -> shutdown encontrado em /var/log/wtmp
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

echo "=== TEMPO DE ATIVIDADE DO SISTEMA ==="
echo "Arquivo de log utilizado: $WTMP_FILE"
echo

# Comando explicado:
# last -xF: mostra eventos especiais com data/hora completa
# awk: encontra primeiro shutdown e o reboot imediatamente anterior a ele,
#      formando o ciclo completo mais recente

PAR_EVENTOS=$(last -xF -f "$WTMP_FILE" | awk '
    /shutdown/ && !shutdown_encontrado {
        shutdown = $5 " " $6 " " $7 " " $8 " " $9
        shutdown_encontrado = 1
        next
    }
    shutdown_encontrado && /reboot/ {
        reboot = $5 " " $6 " " $7 " " $8 " " $9
        print reboot "|" shutdown
        exit
    }
')

if [ -z "$PAR_EVENTOS" ]; then
    echo "Nao foi encontrado um ciclo completo de boot e shutdown no log"
    exit 1
fi

BOOT_TIME=${PAR_EVENTOS%%|*}
SHUTDOWN_TIME=${PAR_EVENTOS#*|}

BOOT_EPOCH=$(date -d "$BOOT_TIME" +%s 2>/dev/null)
SHUTDOWN_EPOCH=$(date -d "$SHUTDOWN_TIME" +%s 2>/dev/null)

if [ -z "$BOOT_EPOCH" ] || [ -z "$SHUTDOWN_EPOCH" ]; then
    echo "Nao foi possivel converter as datas encontradas no log"
    exit 1
fi

DIFERENCA=$((SHUTDOWN_EPOCH - BOOT_EPOCH))

if [ "$DIFERENCA" -lt 0 ]; then
    echo "Os eventos encontrados estao fora de ordem ou o log esta inconsistente"
    exit 1
fi

DIAS=$((DIFERENCA / 86400))
HORAS=$(((DIFERENCA % 86400) / 3600))
MINUTOS=$(((DIFERENCA % 3600) / 60))
SEGUNDOS=$((DIFERENCA % 60))

echo "Boot:      $BOOT_TIME"
echo "Shutdown:  $SHUTDOWN_TIME"
printf 'Uptime:    %d dia(s), %d hora(s), %d minuto(s) e %d segundo(s)\n' "$DIAS" "$HORAS" "$MINUTOS" "$SEGUNDOS"

echo
echo "Nota: o calculo usa o ultimo ciclo completo; se o sistema ainda estiver ativo, o boot atual nao entra nesta conta."