#!/bin/bash

# ==============================================================================
# EXERCÍCIO 20: Atualização de Pacotes
# Objetivo: Crie um script que identifique e liste todos os pacotes que foram atualizados no sistema.
# O script deve mostrar o nome do pacote e a data da atualização.
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "dpkg.log" -o -name "yum.log" -o -name "dnf.log" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log não encontrado ou sem permissão." >&2 && exit 1

echo "=== 🔄 RELATÓRIO DE PACOTES ATUALIZADOS ==="

awk '
    $3 == "upgrade" {
        printf "📅 %-10s às %-8s | 📦 Pacote: %-25s | ⬆️ %s ➔ %s\n", $1, $2, $4, $5, $6
    }
    $4 == "Updated:" {
        pacote = $0; sub(/.*Updated:[ \t]*/, "", pacote)
        printf "📅 %-6s às %-8s | 📦 Pacote: %s\n", $1 " " $2, $3, pacote
    }
' "$LOG_ALVO" | sort -r

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio20.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio20.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio20.sh
# 4. Injete dados falsos simulando atualizações no seu log para o teste:
#    sudo bash -c 'echo "2026-03-13 09:15:00 upgrade bash:amd64 5.0-6ubuntu1 5.0-6ubuntu2" >> /var/log/dpkg.log'
#    sudo bash -c 'echo "2026-03-13 09:20:33 upgrade curl:amd64 7.68.0-1 7.68.0-2" >> /var/log/dpkg.log'
#    sudo bash -c 'echo "2026-03-13 09:25:10 upgrade python3:amd64 3.8.2-1 3.8.5-1" >> /var/log/dpkg.log'
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio20.sh
# ==============================================================================
