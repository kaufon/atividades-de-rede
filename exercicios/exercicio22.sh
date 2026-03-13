#!/bin/bash

# ==============================================================================
# EXERCÍCIO 22: Processos encerrados com erro grave
# Objetivo: Encontrar e listar todos os eventos de "segfault" ou "killed"
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "syslog" -o -name "messages" -o -name "kern.log" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log não encontrado ou sem permissão de leitura." >&2 && exit 1

echo "=== 💥 MORTES DE PROCESSOS E FALHAS DE MEMÓRIA ==="
echo "-----------------------------------------------------------------"

awk '
    BEGIN { IGNORECASE = 1 }
    /(segfault|killed|oom-killer|out of memory)/ {
        data_hora = $1 " " $2 " " $3
        mensagem = $0
        sub(/^([^ ]+ +){3}/, "", mensagem)

        tipo = "🛑 KILLED  "
        if (mensagem ~ /segfault/) tipo = "💥 SEGFAULT"
        if (mensagem ~ /(oom-killer|out of memory)/) tipo = "🧠 OOM/RAM "

        printf "📅 %-16s | %-13s | 📄 %s\n", data_hora, tipo, mensagem
    }
' "$LOG_ALVO"

echo "-----------------------------------------------------------------"

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio22.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio22.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio22.sh
# 4. Injete dados falsos simulando mortes de processos no seu log:
#    sudo bash -c 'echo "Mar 13 10:00:01 wsl kernel: [123.456] meuarquivo[999]: segfault at 0 ip 00007f sp 00007f error 4 in libc.so.6" >> /var/log/syslog'
#    sudo bash -c 'echo "Mar 13 10:05:22 wsl kernel: [234.567] Out of memory: Killed process 1024 (chrome) total-vm:2048000kB" >> /var/log/syslog'
#    sudo bash -c 'echo "Mar 13 10:10:45 wsl systemd[1]: docker.service: Main process exited, code=killed, status=9/KILL" >> /var/log/syslog'
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio22.sh
# ==============================================================================
