#!/bin/bash

# ==============================================================================
# EXERCÍCIO 12: Pacotes Removidos
# Objetivo: Identificar todos os pacotes que foram removidos do sistema
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "dpkg.log" -o -name "yum.log" -o -name "dnf.log" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log não encontrado ou sem permissão." >&2 && exit 1

echo "=== 🗑️ HISTÓRICO DE PACOTES REMOVIDOS ==="

awk '
    $3 ~ /^(remove|purge)$/ {
        printf "📅 %-10s às %-8s | 🛑 %-6s | 📦 Pacote: %-25s | 🏷️ Versão: %s\n", $1, $2, toupper($3), $4, $5
    }
    $4 ~ /^(Removed:|Erased:)$/ {
        acao = $4; sub(/:/, "", acao)
        pacote = $0; sub(/.*(Removed:|Erased:)[ \t]*/, "", pacote)
        printf "📅 %-6s às %-8s | 🛑 %-6s | 📦 Pacote: %s\n", $1 " " $2, $3, toupper(acao), pacote
    }
' "$LOG_ALVO" | sort -r

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio12.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio12.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio12.sh
# 4. Injete dados falsos simulando remoções no seu log para o teste:
#    sudo bash -c "echo \"$(date '+%Y-%m-%d') 10:30:15 remove apache2:amd64 2.4.41\" >> /var/log/dpkg.log"
#    sudo bash -c "echo \"$(date '+%Y-%m-%d') 10:35:00 purge nginx-common:all 1.18.0\" >> /var/log/dpkg.log"
#    sudo bash -c "echo \"$(date -d '2 days ago' '+%Y-%m-%d') 14:00:00 remove vim:amd64 2:8.1.2269\" >> /var/log/dpkg.log"
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio12.sh
# ==============================================================================
