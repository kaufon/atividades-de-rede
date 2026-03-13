#!/bin/bash

# EXERCÍCIO 3: Rastrear o uso do comando su (switch user)
# Objetivo: Mostrar o usuário que executou o comando e para qual usuário ele tentou mudar
# Arquivo de log utilizado: /var/log/auth.log (ou /var/log/secure em sistemas RedHat)

# Verificar qual arquivo de log existe no sistema
if [ -f /var/log/auth.log ]; then
    LOG_FILE="/var/log/auth.log"
elif [ -f /var/log/secure ]; then
    LOG_FILE="/var/log/secure"
else
    echo "Arquivo de log de autenticação não encontrado"
    exit 1
fi

echo "=== RASTREAMENTO DE USO DO COMANDO su (SWITCH USER) ==="
echo

# Comando explicado:
# grep "su\[": busca por linhas que contêm "su[" (processo su)
# awk: extrai data, hora, usuário que executou (after "by") e o usuário alvo (field que vem após "su")
# A mensagem típica é: "su[PID]: (to xxxxx) username on none"

grep "su\[" "$LOG_FILE" | \
    awk '{
        # Extrai data e hora (MMM DD HH:MM:SS)
        data = $1 " " $2 " " $3
        hora = $4
        
        # Procura por "by" e extrai o usuário que executou su
        usuario_origem = ""
        usuario_destino = ""
        
        for (i=1; i<=NF; i++) {
            if ($i == "by") {
                usuario_origem = $(i+1)
                gsub(/[,;]/, "", usuario_origem)
                break
            }
        }
        
        # Procura por "(to" para extrair o usuário de destino
        for (i=1; i<=NF; i++) {
            if ($i ~ /^\(to/) {
                usuario_destino = substr($i, 5)
                gsub(/\)/, "", usuario_destino)
                break
            }
        }
        
        # Se não encontrou, verifica se está entre aspas ou em outro padrão
        if (!usuario_destino) {
            for (i=1; i<=NF; i++) {
                if ($i ~ /to/) {
                    usuario_destino = $(i+1)
                    gsub(/\)/, "", usuario_destino)
                    gsub(/[,;]/, "", usuario_destino)
                    break
                }
            }
        }
        
        printf "Data/Hora: %-20s | De Usuário: %-15s | Para Usuário: %-15s\n", \
            data " " hora, usuario_origem, usuario_destino
    }' | sort

echo
echo "Nota: Este script mostra todas as tentativas de mudança de usuário com o comando su."
