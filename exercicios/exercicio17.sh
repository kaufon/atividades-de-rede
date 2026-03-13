#!/bin/bash

# ==============================================================================
# EXERCÍCIO 17: Qual serviço do sistema está gerando a maior quantidade de logs? 
# Objetivo: Contar a frequência de mensagens por serviço e as listar em ordem decrescente.
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "syslog" -o -name "messages" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log não encontrado ou sem permissão." >&2 && exit 1

echo "=== 📊 TOP GERADORES DE LOGS DO SISTEMA ==="
echo "-----------------------------------------------------------------"

awk '{print $5}' "$LOG_ALVO" | \
    sed -E 's/\[[0-9]+\]:?//; s/:$//' | \
    grep -Ev '^(kernel|)$' | \
    sort | uniq -c | sort -nr | head -n 15 | \
    awk '{ printf "📈 %-6s registros ➔  ⚙️ %s\n", $1, $2 }'

echo "-----------------------------------------------------------------"

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio17.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio17.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio17.sh
# 4. Injete dados falsos no seu log simulando diferentes volumes de serviço:
#    sudo bash -c 'for i in {1..10}; do echo "Mar 13 10:00:00 wsl nginx[123]: requisicao web $i" >> /var/log/syslog; done'
#    sudo bash -c 'for i in {1..25}; do echo "Mar 13 10:05:00 wsl sshd[456]: tentativa de conexao $i" >> /var/log/syslog; done'
#    sudo bash -c 'for i in {1..5}; do echo "Mar 13 10:10:00 wsl cron[789]: tarefa agendada $i" >> /var/log/syslog; done'
#    sudo bash -c 'for i in {1..2}; do echo "Mar 13 10:15:00 wsl systemd[1]: status $i" >> /var/log/syslog; done'
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio17.sh
# ==============================================================================
