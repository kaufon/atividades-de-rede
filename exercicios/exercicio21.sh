#!/bin/bash

# ==============================================================================
# EXERCÍCIO 21: Buscar mensagens de erro ou aviso de um serviço específico
# Objetivo: Localizar eventos de erro/warning gerados por um serviço em execução
# ==============================================================================

SERVICO="${1:-sshd}"

LOGS_ALVO=$(find /var/log -maxdepth 1 -type f \( -name "auth.log" -o -name "syslog" -o -name "messages" -o -name "secure" \) -readable)

[[ -z "$LOGS_ALVO" ]] && echo "Erro: Nenhum arquivo de log encontrado ou sem permissão de leitura." >&2 && exit 1

echo "=== 🔎 DIAGNÓSTICO DE SERVIÇO: ${SERVICO^^} ==="
echo "-----------------------------------------------------------------"

# shellcheck disable=SC2086
awk -v srv="$SERVICO" '
    BEGIN { IGNORECASE = 1; encontrou = 0 }
    
    $0 ~ srv && /(error|warning|warn|fail|failed)/ {
        n = split(FILENAME, caminho, "/")
        arquivo = caminho[n]
        
        data_hora = $1 " " $2 " " $3
        mensagem = $0; sub(/^([^ ]+ +){3}/, "", mensagem)
        
        tipo = "⚠️ AVISO"
        if ($0 ~ /(error|fail|failed)/) tipo = "❌ ERRO "
        
        printf "📁 %-10s | 📅 %-16s | %s | 📄 %s\n", arquivo, data_hora, tipo, mensagem
        encontrou++
    }
    
    END {
        if (encontrou == 0) {
            print "✅ Tudo limpo! Nenhum erro ou aviso encontrado para o serviço: " srv
        }
    }
' $LOGS_ALVO

echo "-----------------------------------------------------------------"

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio21.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio21.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio21.sh
# 4. Injete dados falsos de erros e avisos de um serviço (ex: cron) nos logs:
#    sudo bash -c 'echo "Mar 13 09:00:01 wsl cron[123]: (root) CMD (run-parts /etc/cron.hourly) - WARNING: script execution delayed" >> /var/log/syslog'
#    sudo bash -c 'echo "Mar 13 09:15:22 wsl cron[124]: Error: failed to load configuration from /etc/crontab" >> /var/log/syslog'
#    sudo bash -c 'echo "Mar 13 09:20:00 wsl sshd[999]: pam_unix(sshd:auth): authentication failure; user=root" >> /var/log/auth.log'
# 5. Execute o script passando o nome do serviço que deseja analisar (ex: cron):
#    sudo ./exercicio21.sh cron
# 
# Dica: Se executar sem passar parâmetro (`sudo ./exercicio21.sh`), ele 
# buscará automaticamente por erros no serviço 'sshd' por padrão.
# ==============================================================================
