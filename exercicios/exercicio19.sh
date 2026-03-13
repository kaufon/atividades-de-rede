#!/bin/bash

# ==============================================================================
# EXERCÍCIO 19: Crie um script que monitore as tentativas de login falhas em tempo real[cite: 41].
# Objetivo: O script deve exibir a linha de log imediatamente após o evento ocorrer[cite: 42].
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "auth.log" -o -name "secure" \) -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Arquivo de log ausente ou sem permissão." >&2 && exit 1

echo "=== 🔴 RADAR DE INTRUSÃO (TEMPO REAL) ==="
echo "👀 Monitorando: $LOG_ALVO"
echo "🛑 Pressione [Ctrl + C] para abortar."
echo "-----------------------------------------------------------------"

tail -f -n 0 "$LOG_ALVO" | awk '
    BEGIN { IGNORECASE = 1 }
    /(failed password|authentication failure|invalid user|login incorrect)/ {
        $1 = "🚨 " $1
        print $0
        fflush()
    }
'

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio19.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio19.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio19.sh
# 4. ATENÇÃO: Para testar um monitoramento em tempo real, você precisará de 
#    DOIS terminais abertos simultaneamente no seu WSL.
# 5. No TERMINAL 1, execute o script e deixe-o rodando:
#    sudo ./exercicio19.sh
# 6. No TERMINAL 2, injete falhas de login falsas enquanto observa o Terminal 1:
#    sudo bash -c 'echo "Mar 13 18:45:01 wsl sshd[999]: Failed password for root from 10.0.0.5" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 13 18:45:10 wsl sshd[1000]: Invalid user hacker from 192.168.1.10" >> /var/log/auth.log'
# 7. As mensagens devem aparecer instantaneamente formatadas no Terminal 1!
# ==============================================================================
