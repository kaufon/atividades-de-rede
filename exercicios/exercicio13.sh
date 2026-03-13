#!/bin/bash

# ==============================================================================
# EXERCÍCIO 13: Rastrear comandos de pacotes
# Objetivo: Mostrar quem executou comandos como apt, dpkg, yum e qual ação foi feita
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 3 -type f \( -name "auth.log" -o -name "secure" -o -name "audit.log" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log não encontrado ou sem permissão." >&2 && exit 1

echo "=== 📦 AUDITORIA DE GERENCIAMENTO DE PACOTES ==="

awk '
    /sudo:.*COMMAND=.*(apt|apt-get|dpkg|yum|dnf)/ {
        data_hora = $1 " " $2 " " $3
        
        temp_usr = $0; sub(/.*sudo:[ \t]*/, "", temp_usr); sub(/[ \t:].*/, "", temp_usr)
        usuario = temp_usr
        
        comando = $0; sub(/.*COMMAND=/, "", comando)
        
        acao = "Outros"
        if (comando ~ / (install) /) acao = "Instalação"
        if (comando ~ / (remove|purge|erase) /) acao = "Remoção"
        if (comando ~ / (update|upgrade) /) acao = "Atualização"
        
        printf "📅 %-16s | 👤 Usuário: %-10s | ⚙️ %-12s | 💻 %s\n", data_hora, usuario, acao, comando
    }
    /type=SYSCALL.*exe=".*(apt|apt-get|dpkg|yum|dnf)"/ {
        temp_auid = $0; sub(/.*auid=/, "", temp_auid); sub(/ .*/, "", temp_auid)
        temp_exe = $0; sub(/.*exe="/, "", temp_exe); sub(/".*/, "", temp_exe)
        
        printf "📅 %-16s | 👤 AUID: %-13s | ⚙️ %-12s | 💻 %s\n", "Log do Auditd", temp_auid, "Execução", temp_exe
    }
' "$LOG_ALVO"

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio13.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio13.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio13.sh
# 4. Injete dados falsos simulando uso do apt via sudo no seu log para o teste:
#    sudo bash -c 'echo "Mar 13 14:10:05 wsl sudo:    kauan : TTY=pts/0 ; PWD=/home/kauan ; USER=root ; COMMAND=/usr/bin/apt install nginx" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 13 14:15:22 wsl sudo:    admin : TTY=pts/1 ; PWD=/tmp ; USER=root ; COMMAND=/usr/bin/apt-get update" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 13 14:20:10 wsl sudo:    root : TTY=pts/0 ; PWD=/root ; USER=root ; COMMAND=/usr/bin/dpkg --purge apache2" >> /var/log/auth.log'
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio13.sh
# ==============================================================================
