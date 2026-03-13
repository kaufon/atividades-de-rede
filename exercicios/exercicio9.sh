#!/bin/bash

# ==============================================================================
# EXERCÍCIO 9: Status de Serviços
# Objetivo: Listar a data e o nome dos serviços que tiveram seu status alterado
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "syslog" -o -name "messages" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log não encontrado ou sem permissão." >&2 && exit 1

echo "=== ⚙️ MONITORAMENTO DE SERVIÇOS (SYSTEMD) ==="

awk '
    /systemd\[[0-9]+\]: (Started|Stopped|Reloaded|Restarted)/ {
        data_hora = $1 " " $2 " " $3
        acao = ""
        servico = ""

        for (i=1; i<=NF; i++) {
            if ($i ~ /^(Started|Stopped|Reloaded|Restarted)$/) {
                acao = $i
                servico = $(i+1)
                for (j=i+2; j<=NF; j++) {
                    servico = servico " " $j
                }
                sub(/\.$/, "", servico)
                break
            }
        }
        
        icone = "🔄"
        if (acao == "Started") icone = "▶️ "
        if (acao == "Stopped") icone = "🛑"
        
        printf "📅 %-16s | %s %-10s ➔  %s\n", data_hora, icone, acao, servico
    }
' "$LOG_ALVO"

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio9.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio9.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio9.sh
# 4. Injete dados falsos de serviços do systemd no seu log para o teste:
#    sudo bash -c 'echo "Mar 13 07:15:01 wsl systemd[1]: Started Nginx Web Server." >> /var/log/syslog'
#    sudo bash -c 'echo "Mar 13 07:20:33 wsl systemd[1]: Stopped MySQL Community Server." >> /var/log/syslog'
#    sudo bash -c 'echo "Mar 13 07:25:10 wsl systemd[1]: Reloaded OpenBSD Secure Shell server." >> /var/log/syslog'
#    sudo bash -c 'echo "Mar 13 07:30:05 wsl systemd[1]: Restarted Docker Application Container Engine." >> /var/log/syslog'
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio9.sh
# ==============================================================================
