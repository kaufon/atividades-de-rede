#!/bin/bash

# ==============================================================================
# DESAFIO 1: Auditoria de Falhas de Autenticação
# Objetivo: Relacionar usuários e quantidade de senhas incorretas
# ==============================================================================

LOG_ALVO=$(find /var/log -maxdepth 1 \( -name "auth.log" -o -name "secure" \) -type f -readable -print -quit)

[[ -z "$LOG_ALVO" ]] && echo "Erro: Log não encontrado ou sem permissão." >&2 && exit 1

echo "=== RELATÓRIO DE TENTATIVAS DE LOGIN FALHAS ==="

grep "Failed password" "$LOG_ALVO" | \
    sed -n 's/.*for \(invalid user \)*\([^ ]*\).*/\2/p' | \
    sort | uniq -c | sort -nr | \
    while read -r contagem usuario; do
    printf "Usuário: %-15s | Falhas: %d\n" "$usuario" "$contagem"
done

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
#
# 1. Salve este código em um arquivo chamado: exercicio1.sh
# 2. Torne o arquivo executável rodando no terminal:
#    chmod +x exercicio1.sh
# 3. Como você está no WSL e o log pode estar vazio, injete dados falsos
#    rodando os comandos abaixo:
#    sudo bash -c 'echo "Mar 12 10:00:01 wsl sshd[123]: Failed password for root from 192.168.0.5 port 22" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 12 10:05:22 wsl sshd[124]: Failed password for invalid user admin from 10.0.0.2 port 22" >> /var/log/auth.log'
#    sudo bash -c 'echo "Mar 12 10:05:25 wsl sshd[125]: Failed password for invalid user admin from 10.0.0.2 port 22" >> /var/log/auth.log'
# 4. Execute o script com privilégios de administrador:
#    sudo ./exercicio1.sh
# ==============================================================================
