#!/bin/bash

# EXERCICIO 18: Extrair usuario e metodo de autenticacao de cada login falho
# Objetivo: mostrar, para cada tentativa falha, qual usuario foi usado e por qual metodo
# Arquivos de log utilizados: /var/log/auth.log ou /var/log/secure

if [ -f /var/log/auth.log ]; then
    LOG_FILE="/var/log/auth.log"
elif [ -f /var/log/secure ]; then
    LOG_FILE="/var/log/secure"
else
    echo "Arquivo de log de autenticacao nao encontrado"
    exit 1
fi

echo "=== LOGIN FALHO: USUARIO E METODO DE AUTENTICACAO ==="
echo "Arquivo de log utilizado: $LOG_FILE"
echo

# Comando explicado:
# grep -Ei: filtra eventos tipicos de falha de autenticacao
# awk: extrai usuario e metodo a partir do nome do processo e do texto do evento

grep -Ei 'Failed password|authentication failure|FAILED LOGIN|Login incorrect|Invalid user' "$LOG_FILE" | \
    awk '{
        data_hora = $1 " " $2 " " $3
        processo = $5
        usuario = "desconhecido"
        metodo = processo

        sub(/\[[0-9]+\]:$/, "", metodo)
        sub(/:$/, "", metodo)

        if (metodo == "sshd") {
            metodo = "ssh"
        } else if (metodo == "su") {
            metodo = "su"
        } else if (metodo == "login") {
            metodo = "login"
        } else if (metodo == "gdm-password") {
            metodo = "gdm"
        }

        if (match($0, /Invalid user ([^ ]+)/, partes)) {
            usuario = partes[1]
        } else if (match($0, /for( invalid user)? ([^ ]+)/, partes)) {
            usuario = partes[2]
        } else if (match($0, /user=([^ ]+)/, partes)) {
            usuario = partes[1]
        } else if (match($0, /ruser=([^ ]+)/, partes)) {
            usuario = partes[1]
        }

        gsub(/[,;]/, "", usuario)

        printf "Data/Hora: %-15s | Metodo: %-12s | Usuario: %s\n", data_hora, metodo, usuario
    }'

echo
echo "Nota: o metodo e inferido a partir do processo que gerou a mensagem no log."