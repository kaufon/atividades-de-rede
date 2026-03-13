#!/bin/bash

# ==============================================================================
# EXERCÍCIO 4: Auditar o uso do sudo
# Objetivo: Mostrar o usuário que executou o comando sudo e a data/hora do evento
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 2 -type f \( -name "auth.log" -o -name "secure" -o -name "sudo" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log não encontrado ou sem permissão." >&2 && exit 1

echo "=== AUDITORIA DE COMANDOS PRIVILEGIADOS (SUDO) ==="

awk -F'sudo:[ \t]*' '
    /COMMAND=/ {
        split($1, data_arr, " ")
        data_hora = data_arr[1] " " data_arr[2] " " data_arr[3]

        split($2, resto_arr, "[ \t]*:")
        usuario = resto_arr[1]

        comando = $0
        sub(/.*COMMAND=/, "", comando)

        printf "📅 %-16s | 👤 Usuário: %-12s | ⚡ %s\n", data_hora, usuario, comando
    }
' "$LOG_ALVO" | sort

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio4.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio4.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio4.sh
# 4. Injete dados falsos de uso do 'sudo' no seu log para o teste:
#    sudo bash -c 'echo "Mar 13 10:45:01 wsl sudo:    kauan : TTY=pts/0 ; PWD=/home/kauan ; USER=root ; COMMAND=/usr/bin/apt update" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 13 11:20:33 wsl sudo:    admin : TTY=pts/1 ; PWD=/tmp ; USER=root ; COMMAND=/usr/bin/cat /etc/shadow" >> /var/log/auth.log'
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio4.sh
# ==============================================================================
