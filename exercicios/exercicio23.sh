#!/bin/bash

# EXERCICIO 23: Calcular quanto tempo um usuario permaneceu logado no sistema
# Objetivo: listar as sessoes registradas e somar a duracao total das sessoes encerradas
# Arquivo de log utilizado: /var/log/wtmp

if [ -z "$1" ]; then
    echo "Uso: $0 nome_do_usuario"
    exit 1
fi

USUARIO_ALVO="$1"
WTMP_FILE="/var/log/wtmp"

if [ ! -f "$WTMP_FILE" ]; then
    echo "Arquivo de log $WTMP_FILE nao encontrado"
    exit 1
fi

if ! command -v last >/dev/null 2>&1; then
    echo "Comando 'last' nao encontrado no sistema"
    exit 1
fi

echo "=== TEMPO LOGADO DO USUARIO $USUARIO_ALVO ==="
echo "Arquivo de log utilizado: $WTMP_FILE"
echo

SESSOES=$(last -F -R -f "$WTMP_FILE" "$USUARIO_ALVO" | grep -vE 'wtmp begins|reboot|shutdown')

if [ -z "$SESSOES" ]; then
    echo "Nenhuma sessao encontrada para o usuario '$USUARIO_ALVO'"
    exit 1
fi

echo "$SESSOES"
echo

# Comando explicado:
# a duracao calculada pelo comando 'last' aparece no final da linha entre parenteses
# o awk abaixo soma todas as duracoes ja encerradas, no formato HH:MM ou D+HH:MM

echo "$SESSOES" | awk '
    function soma_duracao(texto, dias, horas, minutos) {
        if (texto ~ /^[0-9]+\+[0-9]{2}:[0-9]{2}$/) {
            split(texto, parte_dia, "+")
            dias = parte_dia[1] + 0
            split(parte_dia[2], hm, ":")
            horas = hm[1] + 0
            minutos = hm[2] + 0
            return (dias * 86400) + (horas * 3600) + (minutos * 60)
        }

        split(texto, hm, ":")
        horas = hm[1] + 0
        minutos = hm[2] + 0
        return (horas * 3600) + (minutos * 60)
    }

    {
        if (match($0, /\(([0-9]+\+[0-9]{2}:[0-9]{2}|[0-9]{2}:[0-9]{2})\)/, duracao)) {
            total += soma_duracao(duracao[1])
            sessoes_encerradas++
        } else if ($0 ~ /still logged in/) {
            sessoes_ativas++
        }
    }
    END {
        dias = int(total / 86400)
        horas = int((total % 86400) / 3600)
        minutos = int((total % 3600) / 60)

        print "Resumo:"
        printf "Sessoes encerradas consideradas: %d\n", sessoes_encerradas
        printf "Sessoes ainda ativas: %d\n", sessoes_ativas
        printf "Tempo total encerrado: %d dia(s), %d hora(s) e %d minuto(s)\n", dias, horas, minutos
    }
'

echo
echo "Nota: sessoes ainda ativas sao listadas, mas nao entram na soma final porque ainda nao possuem logout."