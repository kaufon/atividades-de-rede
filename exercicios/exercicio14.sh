#!/bin/bash

# ==============================================================================
# EXERCÍCIO 14: Análise de Períodos (Tempo de Atividade)
# Objetivo: Analisar a diferença de tempo entre o último boot e desligamento
# ==============================================================================

LOG_WTMP="/var/log/wtmp"

[[ ! -r "$LOG_WTMP" ]] && echo "Erro: Arquivo binário de log ausente ou sem permissão." >&2 && exit 1

echo "=== ⏱️ TEMPO DE ATIVIDADE DO SISTEMA (UPTIME) ==="

last -xF -f "$LOG_WTMP" | awk '
    BEGIN {
        meses["Jan"]="01"; meses["Feb"]="02"; meses["Mar"]="03"; meses["Apr"]="04";
        meses["May"]="05"; meses["Jun"]="06"; meses["Jul"]="07"; meses["Aug"]="08";
        meses["Sep"]="09"; meses["Oct"]="10"; meses["Nov"]="11"; meses["Dec"]="12";
    }
    /^shutdown/ && !fim {
        split($8, t, ":")
        fim = mktime($9 " " meses[$6] " " $7 " " t[1] " " t[2] " " t[3])
        fim_str = $5 ", " $7 " de " $6 " de " $9 " às " $8
        next
    }
    /^reboot/ && fim {
        split($8, t, ":")
        inicio = mktime($9 " " meses[$6] " " $7 " " t[1] " " t[2] " " t[3])
        inicio_str = $5 ", " $7 " de " $6 " de " $9 " às " $8
        
        diferenca = fim - inicio
        if (diferenca > 0) {
            dias = int(diferenca / 86400)
            horas = int((diferenca % 86400) / 3600)
            minutos = int((diferenca % 3600) / 60)
            segundos = diferenca % 60
            
            printf "🟢 Inicialização: %s\n", inicio_str
            printf "🔴 Desligamento : %s\n", fim_str
            printf "⏳ Tempo Ligado : %d dias, %d horas, %d minutos e %d segundos\n", dias, horas, minutos, segundos
        } else {
            print "⚠️ Aviso: Os eventos no log parecem estar inconsistentes."
        }
        exit
    }
    END {
        if (!fim || !inicio) print "⚠️ Nenhum ciclo completo de boot/shutdown encontrado no log."
    }
'

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio14.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio14.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio14.sh
# 4. Execute o script diretamente:
#    ./exercicio14.sh
#
# NOTA PARA USUÁRIOS DE WSL: Como vimos nos exercícios 6 e 7, o WSL não 
# registra ciclos reais de boot e shutdown de kernel no log binário wtmp. 
# Portanto, ao testar no WSL, a mensagem "Nenhum ciclo completo" é o 
# comportamento correto e esperado. O cálculo funcionará perfeitamente 
# em uma máquina Linux real ou VM tradicional.
# ==============================================================================
