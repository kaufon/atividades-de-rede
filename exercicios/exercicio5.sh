#!/bin/bash

# EXERCÍCIO 5: Identificar logins rejeitados por outros motivos
# Objetivo: Encontrar logins rejeitados por:
#           - Usuários inexistentes
#           - Falta de permissão
#           - Outros motivos de rejeição
# Arquivo de log utilizado: /var/log/auth.log (ou /var/log/secure em sistemas RedHat)

# Verificar qual arquivo de log existe no sistema
if [ -f /var/log/auth.log ]; then
    LOG_FILE="/var/log/auth.log"
elif [ -f /var/log/secure ]; then
    LOG_FILE="/var/log/secure"
else
    echo "Arquivo de log de autenticação não encontrado"
    exit 1
fi

echo "=== RELATÓRIO DE LOGINS REJEITADOS POR OUTROS MOTIVOS ==="
echo
echo "Análise de rejeições de login para:"
echo "  1. Usuários inexistentes"
echo "  2. Falta de permissão"
echo "  3. Outros motivos de rejeição"
echo "====================================================="
echo

# Extrair todos os tipos de falhas de login
# grep: busca por linhas que indicam rejeição de login
# awk: extrai e categoriza os motivos

grep -E "(Invalid user|User.*not known|Permission denied|Authentication failure)" "$LOG_FILE" | \
    awk '{
        # Extrai data e hora (MMM DD HH:MM:SS)
        data = $1 " " $2 " " $3
        hora = $4
        
        # Determina o tipo de falha
        tipo_falha = "Outro motivo"
        usuario = "desconhecido"
        
        # Procura pelo nome do usuário
        for (i=1; i<=NF; i++) {
            if ($i == "user=" || $i == "User") {
                if ($i == "user=") {
                    usuario = $(i+1)
                    gsub(/[,;]/, "", usuario)
                } else {
                    usuario = $(i+1)
                }
                break
            }
        }
        
        # Categoriza o motivo da falha
        if ($0 ~ /Invalid user/) {
            tipo_falha = "Usuário inexistente (Invalid user)"
        } else if ($0 ~ /not known/) {
            tipo_falha = "Usuário desconhecido (not known)"
        } else if ($0 ~ /Permission denied/) {
            tipo_falha = "Permissão negada (Permission denied)"
        } else if ($0 ~ /Authentication failure/) {
            tipo_falha = "Falha de autenticação"
        }
        
        printf "Data/Hora: %-20s | Usuário: %-20s | Motivo: %s\n", \
            data " " hora, usuario, tipo_falha
    }' | sort

echo
echo "====================================================="
echo

# Também gera um sumário por tipo de falha
echo "SUMÁRIO POR TIPO DE FALHA:"
echo

grep -E "(Invalid user|User.*not known|Permission denied|Authentication failure)" "$LOG_FILE" | \
    awk '{
        if ($0 ~ /Invalid user/) {
            tipo = "Usuário inexistente"
        } else if ($0 ~ /not known/) {
            tipo = "Usuário desconhecido"
        } else if ($0 ~ /Permission denied/) {
            tipo = "Permissão negada"
        } else if ($0 ~ /Authentication failure/) {
            tipo = "Falha de autenticação"
        } else {
            tipo = "Outro motivo"
        }
        
        count[tipo]++
    }
    END {
        for (tipo in count) {
            printf "%-30s: %d ocorrências\n", tipo, count[tipo]
        }
    }' | sort -t: -k2 -rn

echo
echo "Nota: Este script identifica todos os tipos de rejeição de login diferentes de 'senha incorreta'."
