#!/bin/bash

# EXERCICIO 11: Listar pacotes instalados na ultima semana
# Objetivo: mostrar a data da instalacao e o nome do pacote
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

echo "=== PACOTES INSTALADOS NA ULTIMA SEMANA ==="
echo "Arquivo de log utilizado: $LOG_FILE"
echo

if [ "$LOG_FILE" = "/var/log/dpkg.log" ]; then
    DATA_LIMITE=$(date -d '7 days ago' +%F)

    # Comando explicado:
    # awk: no dpkg.log a data ja vem em formato YYYY-MM-DD, o que permite comparacao direta
    # $3 == "install": mantem apenas operacoes de instalacao

    awk -v limite="$DATA_LIMITE" '$1 >= limite && $3 == "install" {
        printf "Data/Hora: %-19s | Pacote: %-35s | Versao: %s\n", $1 " " $2, $4, $5
    }' "$LOG_FILE"
else
    AGORA=$(date +%s)

    # Comando explicado:
    # logs yum/dnf usam mes por extenso, entao convertemos a data para epoch com mktime
    # e filtramos apenas eventos mais novos que 7 dias

    awk -v agora="$AGORA" '
        BEGIN {
            meses["Jan"] = 1; meses["Feb"] = 2; meses["Mar"] = 3; meses["Apr"] = 4;
            meses["May"] = 5; meses["Jun"] = 6; meses["Jul"] = 7; meses["Aug"] = 8;
            meses["Sep"] = 9; meses["Oct"] = 10; meses["Nov"] = 11; meses["Dec"] = 12;
            ano = strftime("%Y", agora)
            limite = agora - 604800
        }
        /Installed:/ {
            tempo = $3
            gsub(/:/, " ", tempo)
            evento = mktime(ano " " meses[$1] " " $2 " " tempo)
            if (evento >= limite) {
                pacote = substr($0, index($0, "Installed:") + 11)
                printf "Data/Hora: %-19s | Pacote: %s\n", $1 " " $2 " " $3, pacote
            }
        }
    ' "$LOG_FILE"
fi

echo
echo "Nota: em sistemas RPM, o ano atual e usado para converter a data do log em epoch."