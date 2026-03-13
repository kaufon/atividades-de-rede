#!/bin/bash

# ==============================================================================
# EXERCÍCIO 23: Calcular o tempo de sessão do usuário
# Objetivo: Somar o tempo que um usuário permaneceu logado no sistema
# ==============================================================================

USUARIO=${1:-$USER}
LOG_ALVO="/var/log/wtmp"

[[ ! -r "$LOG_ALVO" ]] && echo "Erro: Arquivo binário de log ausente ou sem permissão." >&2 && exit 1

echo "=== ⏱️ AUDITORIA DE TEMPO DE SESSÃO: ${USUARIO^^} ==="
echo "-----------------------------------------------------------------"

last -w -f "$LOG_ALVO" "$USUARIO" | awk -v user="$USUARIO" '
    $1 == user {
        duracao = $NF
        gsub(/[()]/, "", duracao)

        if (duracao == "in") {
            ativas++
        } else if (duracao ~ /:/) {
            dias = 0
            if (duracao ~ /\+/) {
                split(duracao, p_dias, "+")
                dias = p_dias[1]
                duracao = p_dias[2]
            }
            split(duracao, p_hora, ":")
            
            total_minutos += (dias * 1440) + (p_hora[1] * 60) + p_hora[2]
            encerradas++
        }
    }
    END {
        if (encerradas == 0 && ativas == 0) {
            print "⚠️ Nenhum registro de sessão encontrado para este usuário."
            exit
        }
        
        dias_totais = int(total_minutos / 1440)
        horas_totais = int((total_minutos % 1440) / 60)
        minutos_restantes = total_minutos % 60
        
        printf "📊 RESUMO GERAL:\n"
        printf "🟢 Sessões em andamento: %d\n", ativas + 0
        printf "🔴 Sessões finalizadas : %d\n", encerradas + 0
        printf "⏳ Tempo total logado  : %d dias, %d horas e %d minutos\n", dias_totais, horas_totais, minutos_restantes
    }
'

echo "-----------------------------------------------------------------"

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio23.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio23.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio23.sh
# 4. Assim como nos exercícios 6, 7 e 14, este script lê um arquivo binário 
#    (/var/log/wtmp), então não podemos injetar dados com o comando 'echo'.
# 5. Execute o script passando o nome de um usuário (ou rode sem parâmetros 
#    para que o script busque automaticamente pelo seu próprio usuário atual):
#    ./exercicio23.sh root
#    ./exercicio23.sh kauan
#    ./exercicio23.sh
# ==============================================================================
