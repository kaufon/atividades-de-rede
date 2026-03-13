#!/bin/bash

# EXERCICIO 19: Monitorar tentativas de login falhas em tempo real
# Objetivo: exibir imediatamente as linhas de log que registrarem novas falhas de login
# Arquivos de log utilizados: /var/log/auth.log ou /var/log/secure

if [ -f /var/log/auth.log ]; then
    LOG_FILE="/var/log/auth.log"
elif [ -f /var/log/secure ]; then
    LOG_FILE="/var/log/secure"
else
    echo "Arquivo de log de autenticacao nao encontrado"
    exit 1
fi

echo "=== MONITORAMENTO EM TEMPO REAL DE LOGIN FALHO ==="
echo "Arquivo de log utilizado: $LOG_FILE"
echo "Pressione Ctrl+C para encerrar o monitoramento."
echo

# Comando explicado:
# tail -Fn0 acompanha o crescimento do arquivo sem mostrar historico anterior
# grep --line-buffered garante exibicao imediata de cada nova linha encontrada

tail -Fn0 "$LOG_FILE" | grep --line-buffered -Ei 'Failed password|authentication failure|FAILED LOGIN|Login incorrect|Invalid user'