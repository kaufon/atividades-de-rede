#!/bin/bash

# ==============================================================================
# EXERCÍCIO 16: Análise de falhas críticas e erros
# Objetivo: Listar mensagens contendo "critical", "fatal" ou "segfault"
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "syslog" -o -name "messages" -o -name "kern.log" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log ausente ou sem permissão de leitura." >&2 && exit 1

echo "=== 🔥 DETECÇÃO DE FALHAS CRÍTICAS E ERROS GRAVES ==="
echo "-----------------------------------------------------------------"

awk '
    BEGIN { IGNORECASE = 1 }
    /critical|fatal|segfault/ {
        tipo = "⚠️  ALERTA"
        if ($0 ~ /critical/) tipo = "🚨 CRITICAL"
        if ($0 ~ /fatal/) tipo = "💀 FATAL"
        if ($0 ~ /segfault/) tipo = "💥 SEGFAULT"
        
        data_hora = $1 " " $2 " " $3
        
        mensagem = $0
        sub(/^([^ ]+ +){3}/, "", mensagem)
        
        printf "📅 %-16s | %-13s | 📄 %s\n", data_hora, tipo, mensagem
    }
' "$LOG_ALVO"

echo "-----------------------------------------------------------------"

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio16.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio16.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio16.sh
# 4. Injete dados falsos simulando falhas graves no seu log para o teste:
#    sudo bash -c "echo \"$(date '+%b %e' | sed 's/  / /g') 16:20:01 wsl systemd[1]: Unit nginx.service entered failed state.\" >> /var/log/syslog"
#    sudo bash -c "echo \"$(date '+%b %e' | sed 's/  / /g') 16:25:10 wsl kernel: [  123.456] traps: myapp[1234] general protection ip:7f8b9c sp:7ffe error:0 in libc.so.6[segfault at 000000]\" >> /var/log/syslog"
#    sudo bash -c "echo \"$(date '+%b %e' | sed 's/  / /g') 16:30:45 wsl mysqld[999]: [ERROR] [MY-012345] [InnoDB] Fatal error: cannot allocate memory for the buffer pool\" >> /var/log/syslog"
#    sudo bash -c "echo \"$(date '+%b %e' | sed 's/  / /g') 16:35:00 wsl dockerd[888]: time=\"2026-03-13\" level=critical msg=\"Failed to start container: mount failed\"\" >> /var/log/syslog"
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio16.sh
# ==============================================================================
