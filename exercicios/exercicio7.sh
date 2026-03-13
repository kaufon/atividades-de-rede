#!/bin/bash

# ==============================================================================
# EXERCÍCIO 7: Eventos de Desligamento e Reinicialização
# Objetivo: Encontrar e listar todos os eventos de shutdown e reboot do sistema
# ==============================================================================

LOG_WTMP="/var/log/wtmp"

[[ ! -r "$LOG_WTMP" ]] && echo "Erro: Arquivo binário de log ausente ou sem permissão." >&2 && exit 1

echo "=== HISTÓRICO DE ENERGIA DO SISTEMA ==="

last -x shutdown reboot -f "$LOG_WTMP" | awk '
    /^reboot/   { printf "🔄 %-10s ➔ %s, %02d de %s às %s\n", "REBOOT", $5, $7, $6, $8 }
    /^shutdown/ { printf "🛑 %-10s ➔ %s, %02d de %s às %s\n", "SHUTDOWN", $5, $7, $6, $8 }
' 

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio7.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio7.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio7.sh
# 4. ATENÇÃO: Assim como no exercício anterior, o arquivo /var/log/wtmp é um 
#    log BINÁRIO estruturado em C (struct utmp). NÃO podemos usar o comando 
#    'echo' para injetar textos nele, pois isso corromperia o arquivo.
# 5. Execute o script diretamente:
#    ./exercicio7.sh
# 
# Nota para o WSL: Como o WSL opera como um subsistema, o comando 'last'
# provavelmente retornará uma lista vazia ou apenas um evento isolado, pois ele
# não passa pelas rotinas clássicas de boot/shutdown do Systemd de um kernel 
# Linux tradicional.
# ==============================================================================
