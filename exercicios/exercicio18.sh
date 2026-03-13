#!/bin/bash

# ==============================================================================
# EXERCÍCIO 18: Extrair usuário e método de autenticação de cada login falho
# Objetivo: Mostrar, para cada tentativa falha, qual usuário foi usado e por qual método
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "auth.log" -o -name "secure" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log não encontrado ou sem permissão." >&2 && exit 1

echo "=== 🕵️ RASTREAMENTO DE TENTATIVAS DE INVASÃO/FALHAS ==="

awk '
    BEGIN {
        IGNORECASE = 1
        mapa["sshd"] = "SSH (Rede)"
        mapa["su"] = "SU (Troca de Usuário)"
        mapa["sudo"] = "SUDO (Privilégio)"
        mapa["login"] = "TTY (Console Local)"
        mapa["gdm-password"] = "Interface Gráfica"
    }
    /(failed|failure|incorrect|invalid user)/ {
        data_hora = $1 " " $2 " " $3
        
        proc = $5
        sub(/\[[0-9]+\]:?$/, "", proc)
        sub(/:$/, "", proc)
        
        metodo = (proc in mapa) ? mapa[proc] : proc
        usuario = "Desconhecido"

        for (i=1; i<=NF; i++) {
            if ($i == "for") {
                usuario = ($(i+1) == "invalid" && $(i+2) == "user") ? $(i+3) : $(i+1)
                break
            } else if ($i ~ /^user=/) {
                split($i, arr, "=")
                usuario = (arr[2] != "") ? arr[2] : $(i+1)
                break
            }
        }
        
        gsub(/[^a-zA-Z0-9_-]/, "", usuario)

        if (usuario != "" && usuario != "Desconhecido") {
            printf "📅 %-16s | 🛡️ Método: %-22s | 👤 Usuário: %s\n", data_hora, metodo, usuario
        }
    }
' "$LOG_ALVO"

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio18.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio18.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio18.sh
# 4. Injete dados falsos simulando falhas de autenticação no seu log:
#    sudo bash -c 'echo "Mar 13 18:00:01 wsl sshd[123]: Failed password for root from 192.168.0.5 port 22" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 13 18:05:22 wsl sshd[124]: Failed password for invalid user admin from 10.0.0.2 port 22" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 13 18:10:45 wsl su[125]: pam_unix(su:auth): authentication failure; logname= uid=1000 euid=0 tty=/dev/pts/0 ruser=kauan rhost=  user=root" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 13 18:15:30 wsl login[126]: FAILED LOGIN 1 FROM tty1 FOR visitante, Authentication failure" >> /var/log/auth.log'
# 5. Execute o script com privilégios de administrador:
#    sudo ./exercicio18.sh
# ==============================================================================
