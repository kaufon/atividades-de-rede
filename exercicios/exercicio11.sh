#!/bin/bash

# ==============================================================================
# EXERCÍCIO 11: Análise de Pacotes e Segurança Interna
# Objetivo: Listar pacotes instalados na última semana com a data da instalação [cite: 29]
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "dpkg.log" -o -name "yum.log" -o -name "dnf.log" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log de pacotes ausente ou sem permissão." >&2 && exit 1

echo "=== 📦 PACOTES INSTALADOS NOS ÚLTIMOS 7 DIAS ==="

REGEX_DPKG=$(for i in {0..7}; do date -d "$i days ago" '+%Y-%m-%d'; done | paste -sd '|')
REGEX_YUM=$(for i in {0..7}; do date -d "$i days ago" '+%b %e' | sed 's/  / /g'; done | paste -sd '|')

if [[ "$LOG_ALVO" == *dpkg.log ]]; then
    grep -E "($REGEX_DPKG)" "$LOG_ALVO" | awk '/ install / {
        printf "📅 %-10s às %-8s | 📦 Pacote: %-25s | 🏷️ Versão: %s\n", $1, $2, $4, $5
    }'
else
    grep -E "($REGEX_YUM)" "$LOG_ALVO" | awk '/Installed:/ {
        pacote = $0; sub(/.*Installed:[ \t]*/, "", pacote)
        printf "📅 %-6s às %-8s | 📦 Pacote: %s\n", $1 " " $2, $3, pacote
    }'
fi

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio11.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio11.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio11.sh
# 4. Injete dados falsos simulando instalações no seu log (usamos comandos 
#    dinâmicos para gerar datas reais dos últimos 7 dias para o teste funcionar):
#    sudo bash -c "echo \"$(date '+%Y-%m-%d') 10:15:30 startup archives unpack\" >> /var/log/dpkg.log"
#    sudo bash -c "echo \"$(date '+%Y-%m-%d') 10:15:31 install htop:amd64 <none> 3.0.5-7\" >> /var/log/dpkg.log"
#    sudo bash -c "echo \"$(date -d '3 days ago' '+%Y-%m-%d') 14:22:10 install nginx:amd64 <none> 1.18.0-2\" >> /var/log/dpkg.log"
#    sudo bash -c "echo \"$(date -d '10 days ago' '+%Y-%m-%d') 09:00:00 install pacote-antigo:amd64 <none> 1.0.0\" >> /var/log/dpkg.log"
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio11.sh
# ==============================================================================
