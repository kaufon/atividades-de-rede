#!/bin/bash

# ==============================================================================
# EXERCÍCIO 6: Quando o sistema foi inicializado pela última vez?
# Objetivo: Mostrar a data e a hora do último boot
# ==============================================================================

LOG_WTMP="/var/log/wtmp"

[[ ! -r "$LOG_WTMP" ]] && echo "Erro: Arquivo binário de log ausente ou sem permissão." >&2 && exit 1

echo "=== HISTÓRICO DE INICIALIZAÇÃO (BOOT) ==="

last reboot -f "$LOG_WTMP" | awk '
    /^reboot/ {
        printf "🚀 Último Boot Registrado: %s, %s de %s às %s\n", $5, $7, $6, $8
        encontrado = 1
        exit
    }
    END {
        if (!encontrado) print "⚠️ Nenhum registro de boot encontrado."
    }
'

# ==============================================================================
# TUTORIAL DE COMO TESTAR:
# 
# 1. Salve este código em um arquivo chamado: exercicio6.sh
# 2. Remova possíveis quebras de linha invisíveis do Windows (CRLF para LF):
#    sed -i 's/\r$//' exercicio6.sh
# 3. Torne o arquivo executável rodando no terminal: 
#    chmod +x exercicio6.sh
# 4. ATENÇÃO: Diferente do auth.log, o arquivo /var/log/wtmp é um log BINÁRIO 
#    e não um arquivo de texto. Portanto, NÃO podemos usar o comando 'echo' 
#    para injetar dados falsos nele sem corrompê-lo.
# 5. Execute o script diretamente:
#    ./exercicio6.sh
# 
# Nota para usuários de WSL: O WSL tradicional não passa por um processo de boot 
# com o kernel real, então é normal que o log /var/log/wtmp esteja vazio para 
# eventos de 'reboot' e o script mostre a mensagem de "Nenhum registro". Em 
# servidores Linux reais ou VMs, ele exibirá a data corretamente.
# ==============================================================================
