#!/bin/bash

# ==============================================================================
# EXERCÍCIO 15: Análise de Períodos (Tempo de Atividade)
# Objetivo: Exibir apenas os eventos que ocorreram entre 14h e 15h de um dia específico
# ==============================================================================

DATA_ALVO=${1:-$(date +%Y-%m-%d)}
LOG_ALVO=${2:-$(find /var/log -maxdepth 1 -type f \( -name "syslog" -o -name "messages" \) -readable -print -quit)}

[[ ! -r "$LOG_ALVO" ]] && echo "Erro: Arquivo de log ausente ou sem permissão de leitura." >&2 && exit 1

PADRAO_DATA=$(date -d "$DATA_ALVO" '+%b[[:space:]]+%-d' 2>/dev/null)

[[ -z "$PADRAO_DATA" ]] && echo "Erro: Data fornecida é inválida. Formato esperado: AAAA-MM-DD." >&2 && exit 1

echo "=== 🕒 EVENTOS REGISTRADOS ENTRE 14:00 E 14:59 ==="
echo "📅 Data: $DATA_ALVO | 📁 Log: $LOG_ALVO"
echo "-----------------------------------------------------------------"

grep -E "^${PADRAO_DATA}[[:space:]]+14:[0-5][0-9]:[0-5][0-9]" "$LOG_ALVO" | \
    sed 's/^/🔹 /'

echo "-----------------------------------------------------------------"

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio15.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio15.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio15.sh
# 4. Injete dados falsos no seu log simulando horários variados (note que 
#    apenas os eventos que ocorrem entre as 14:00 e 14:59 devem aparecer):
#    sudo bash -c "echo \"$(date '+%b %e' | sed 's/  / /g') 13:59:59 wsl systemd[1]: Evento ignorado (antes das 14h)\" >> /var/log/syslog"
#    sudo bash -c "echo \"$(date '+%b %e' | sed 's/  / /g') 14:00:01 wsl systemd[1]: Evento capturado (dentro do horario)\" >> /var/log/syslog"
#    sudo bash -c "echo \"$(date '+%b %e' | sed 's/  / /g') 14:45:33 wsl kernel: Evento capturado (dentro do horario)\" >> /var/log/syslog"
#    sudo bash -c "echo \"$(date '+%b %e' | sed 's/  / /g') 15:00:00 wsl crond[99]: Evento ignorado (exatamente as 15h)\" >> /var/log/syslog"
# 5. Execute o script passando a data de hoje (AAAA-MM-DD):
#    sudo ./exercicio15.sh "$(date +%Y-%m-%d)"
# ==============================================================================
