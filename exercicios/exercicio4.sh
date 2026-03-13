#!/bin/bash

# EXERCÍCIO 4: Auditar o uso do sudo
# Objetivo: Mostrar o usuário que executou o comando sudo e a data/hora do evento
# Arquivo de log utilizado: /var/log/auth.log ou /var/log/sudo (Linux Debian/Ubuntu)
#                           /var/log/secure ou /var/log/audit/audit.log (RedHat/CentOS)

echo "=== AUDITORIA DE USO DO SUDO ==="
echo

# Descobrir qual arquivo de log usar (ordem de preferência)
LOG_FILES=("/var/log/sudo" "/var/log/auth.log" "/var/log/secure" "/var/log/audit/audit.log")
LOG_FILE=""

for file in "${LOG_FILES[@]}"; do
    if [ -f "$file" ]; then
        LOG_FILE="$file"
        break
    fi
done

if [ -z "$LOG_FILE" ]; then
    echo "Nenhum arquivo de log de sudo encontrado"
    exit 1
fi

echo "Arquivo de log utilizado: $LOG_FILE"
echo

# Comando explicado:
# grep "sudo": busca por linhas que contêm "sudo"
# Vai extrair:
#   - Data e hora do evento
#   - Usuário que executou o comando sudo
#   - Comando que foi executado (quando disponível)
#   - Usuário alvo (se aplicável)

if [ "$LOG_FILE" == "/var/log/sudo" ]; then
    # Formato do /var/log/sudo é mais estruturado
    grep -E ".*" "$LOG_FILE" | \
        awk '{
            # Extrai data, hora e informações do sudo
            # Formato típico inclui timestamp e informações estruturadas
            printf "Data/Hora: %-20s | Usuário: %-15s | Informação: %s\n", \
                $1 " " $2, $3, substr($0, index($0,$4))
        }' | sort
else
    # Formato do /var/log/auth.log ou /var/log/secure
    grep "sudo:" "$LOG_FILE" | \
        awk '{
            # Extrai data e hora (MMM DD HH:MM:SS)
            data = $1 " " $2 " " $3
            hora = $4
            
            # Procura pelo usuário que executou sudo
            # Formato: "sudo: username : TTY=pts/0"
            usuario = ""
            for (i=1; i<=NF; i++) {
                if ($i == "sudo:" && $(i+1) != "pam_unix(sudo:session):" ) {
                    usuario = $(i+1)
                    gsub(/:/, "", usuario)
                    break
                }
            }
            
            # Extrai o comando e informações adicionais
            comando = substr($0, index($0, $7))
            
            printf "Data/Hora: %-20s | Usuário: %-15s | Comando: %s\n", \
                data " " hora, usuario, comando
        }' | sort
fi

echo
echo "Nota: Este script mostra todas as execuções do comando sudo no sistema."
echo "      Importante para auditoria de segurança e controle de acesso privilegiado."
