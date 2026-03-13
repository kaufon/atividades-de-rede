#!/bin/bash

# ==============================================================================
# EXERCÍCIO 5: Identificar logins rejeitados por outros motivos 
# Objetivo: Encontrar logins rejeitados por usuários inexistentes ou falta de permissão 
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 2 -type f \( -name "auth.log" -o -name "secure" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log não encontrado ou sem permissão." >&2 && exit 1

echo "=== RELATÓRIO DE REJEIÇÕES DE ACESSO ==="
echo

awk '
    /(Invalid user|not known|Permission denied|Authentication failure)/ {
        data = $1 " " $2 " " $3
        usuario = "N/A"
        
        if (/Invalid user/) {
            motivo = "Usuário Inexistente"
            usuario = $NF
        } else if (/not known/) {
            motivo = "Usuário Desconhecido"
            for(i=1;i<=NF;i++) if($i=="User") usuario=$(i+1)
        } else if (/Permission denied/) {
            motivo = "Permissão Negada"
            for(i=1;i<=NF;i++) if($i=="for") usuario=$(i+1)
        } else if (/Authentication failure/) {
            motivo = "Falha de Autenticação"
            for(i=1;i<=NF;i++) if(match($i, /user=.*/)) { split($i, a, "="); usuario=a[2] }
        }

        gsub(/[^a-zA-Z0-9_-]/, "", usuario)
        
        printf "📅 %-16s | 👤 Usuário: %-15s | 🛑 %s\n", data, usuario, motivo
        resumo[motivo]++
    }
    END {
        print "\n=== SUMÁRIO ESTATÍSTICO ==="
        for (m in resumo) {
            printf "🔸 %-22s: %d\n", m, resumo[m]
        }
    }
' "$LOG_ALVO"

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio5.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio5.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio5.sh
# 4. Injete dados falsos de rejeições diversas no seu log para o teste:
#    sudo bash -c 'echo "Mar 13 12:00:01 wsl sshd[333]: Invalid user fantasma from 10.0.0.5" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 13 12:05:10 wsl sshd[334]: User visitante not known" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 13 12:10:22 wsl sshd[335]: Permission denied for root from 192.168.1.10" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 13 12:15:40 wsl su[336]: pam_unix(su:auth): authentication failure; logname= uid=1000 euid=0 tty=/dev/pts/0 ruser=kauan rhost=  user=root" >> /var/log/auth.log'
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio5.sh
# ==============================================================================
