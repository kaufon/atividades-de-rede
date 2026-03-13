#!/bin/bash

# EXERCICIO 13: Rastrear o uso de apt, apt-get, dnf, yum ou dpkg
# Objetivo: mostrar quem executou o comando e qual acao foi realizada
# Arquivos de log utilizados: /var/log/auth.log, /var/log/secure ou /var/log/audit/audit.log

LOG_FILES=("/var/log/auth.log" "/var/log/secure" "/var/log/audit/audit.log")
LOG_FILE=""

for file in "${LOG_FILES[@]}"; do
    if [ -f "$file" ]; then
        LOG_FILE="$file"
        break
    fi
done

if [ -z "$LOG_FILE" ]; then
    echo "Nenhum log de auditoria/autenticacao foi encontrado"
    exit 1
fi

echo "=== RASTREAMENTO DE COMANDOS DE GERENCIAMENTO DE PACOTES ==="
echo "Arquivo de log utilizado: $LOG_FILE"
echo

if [ "$LOG_FILE" = "/var/log/audit/audit.log" ]; then
    grep -Ei 'comm="(apt|apt-get|dpkg|yum|dnf)"|exe=".*/(apt|apt-get|dpkg|yum|dnf)"' "$LOG_FILE" | \
        awk '{
            data_hora = "auditd"
            usuario = "desconhecido"
            acao = "acao nao identificada"

            if (match($0, /auid=([0-9]+)/, auid)) {
                usuario = auid[1]
            }

            if (match($0, /comm="([^"]+)"/, cmd)) {
                acao = cmd[1]
            }

            printf "Origem: %-19s | Usuario/AUID: %-10s | Comando: %s\n", data_hora, usuario, acao
        }'
else
    grep -E 'sudo: .*COMMAND=.*(apt|apt-get|dpkg|yum|dnf)' "$LOG_FILE" | \
        awk '{
            data_hora = $1 " " $2 " " $3
            usuario = "desconhecido"
            comando = ""
            acao = "acao nao identificada"

            for (i = 1; i <= NF; i++) {
                if ($i == "sudo:") {
                    usuario = $(i + 1)
                    gsub(/:/, "", usuario)
                }
            }

            if (match($0, /COMMAND=([^;]+)/, cmd)) {
                comando = cmd[1]
                if (comando ~ / install( |$)/) {
                    acao = "install"
                } else if (comando ~ / remove( |$)| purge( |$)/) {
                    acao = "remove"
                } else if (comando ~ / upgrade( |$)| dist-upgrade( |$)/) {
                    acao = "upgrade"
                } else if (comando ~ / update( |$)/) {
                    acao = "update"
                } else {
                    acao = "outra acao"
                }
            }

            printf "Data/Hora: %-15s | Usuario: %-15s | Acao: %-12s | Comando: %s\n", data_hora, usuario, acao, comando
        }'
fi

echo
echo "Nota: quando o log utilizado e o auditd, o identificador do usuario pode aparecer como AUID numerico."