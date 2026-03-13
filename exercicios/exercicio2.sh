#!/bin/bash

# ==============================================================================
# DESAFIO 2: Relatório de Logins Bem-Sucedidos
# Objetivo: Mostrar o nome do usuário e a data/hora do acesso
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "auth.log" -o -name "secure" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log não encontrado ou sem permissão de leitura." >&2 && exit 1

echo "=== RELATÓRIO DE ACESSOS AUTORIZADOS ==="

awk '
    /Accepted/ {
        data_hora = $1 " " $2 " " $3
        for (i=1; i<=NF; i++) {
            if ($i == "for") {
                usuario = $(i+1)
                break
            }
        }
        printf "📅 Data/Hora: %-16s | 👤 Usuário: %-15s\n", data_hora, usuario
    }
' "$LOG_ALVO" | sort

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
#
# 1. Salve este código em um arquivo chamado: exercicio2.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio2.sh
# 3. Torne o arquivo executável rodando no terminal:
#    chmod +x exercicio2.sh
# 4. Injete dados falsos de login com sucesso no seu log para o teste:
#    sudo bash -c 'echo "Mar 12 11:30:00 wsl sshd[999]: Accepted password for admin from 10.0.0.5 port 22 ssh2" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 12 11:45:12 wsl sshd[1020]: Accepted publickey for root from 192.168.1.100 port 22 ssh2" >> /var/log/auth.log'
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio2.sh
# ==============================================================================
