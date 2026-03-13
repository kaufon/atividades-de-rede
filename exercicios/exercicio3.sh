#!/bin/bash

# ==============================================================================
# EXERCÍCIO 3: Rastrear o uso do comando su (switch user)
# Objetivo: Mostrar o usuário que executou o comando e para qual usuário ele tentou mudar
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "auth.log" -o -name "secure" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log não encontrado ou sem permissão." >&2 && exit 1

echo "=== RASTREAMENTO DE TROCA DE USUÁRIOS (SU) ==="

awk '
    /su\[[0-9]+\]:/ && /by/ {
        data_hora = $1 " " $2 " " $3
        
        origem = $0
        sub(/.* by /, "", origem)
        sub(/ .*/, "", origem)
        sub(/\(.*/, "", origem)

        destino = $0
        sub(/.* for (user )?/, "", destino)
        sub(/ .*/, "", destino)
        sub(/\(.*/, "", destino)

        if (origem != "" && destino != "") {
            printf "📅 Data/Hora: %-16s | 👤 De: %-12s ➔  🎯 Para: %-12s\n", data_hora, origem, destino
        }
    }
' "$LOG_ALVO"

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio3.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio3.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio3.sh
# 4. Injete dados falsos de uso do comando 'su' no seu log para o teste:
#    sudo bash -c 'echo "Mar 13 09:15:22 wsl su[111]: pam_unix(su:session): session opened for user root(uid=0) by kauan(uid=1000)" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 13 09:20:05 wsl su[222]: Successful su for admin by root" >> /var/log/auth.log'
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio3.sh
# ==============================================================================
