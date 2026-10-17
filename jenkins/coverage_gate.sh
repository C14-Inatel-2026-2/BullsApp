#!/usr/bin/env bash
# Gate de cobertura da camada de controllers.
#
# Uso: bash jenkins/coverage_gate.sh <lcov.info> <minimo%> <arquivo> [arquivo...]
#
# Soma as linhas cobertas (LH) e as linhas executáveis (LF) do lcov.info só
# para os arquivos informados, e falha se:
#   - algum arquivo não aparece no relatório (nenhum teste carrega ele), ou
#   - a cobertura somada ficar abaixo do mínimo.
#
# Um arquivo que nenhum teste importa simplesmente não aparece no lcov.info.
# Se ele fosse ignorado, a cobertura ficaria artificialmente alta; por isso
# a ausência conta como falha.
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "uso: $0 <lcov.info> <minimo%> <arquivo> [arquivo...]" >&2
  exit 2
fi

lcov="$1"
min="$2"
shift 2

if [ ! -f "$lcov" ]; then
  echo "ERRO: relatório de cobertura não encontrado: $lcov" >&2
  exit 1
fi

awk -v min="$min" -v files="$*" '
  BEGIN {
    n = split(files, alvo, " ")
    for (i = 1; i <= n; i++) { lf[alvo[i]] = -1; lh[alvo[i]] = 0 }
  }
  /^SF:/ {
    atual = substr($0, 4)
    gsub(/\\/, "/", atual)            # no Windows o caminho vem com \
    sub(/^.*\/lib\//, "lib/", atual)  # caminho absoluto -> lib/...
    next
  }
  /^LF:/ && (atual in lf) { lf[atual] = substr($0, 4) + 0; next }
  /^LH:/ && (atual in lh) { lh[atual] = substr($0, 4) + 0; next }
  END {
    falhou = 0; totf = 0; toth = 0
    for (i = 1; i <= n; i++) {
      f = alvo[i]
      if (lf[f] < 0) {
        printf "  SEM COBERTURA  %s (nenhum teste carrega este arquivo)\n", f
        falhou = 1
        continue
      }
      pct = lf[f] ? 100 * lh[f] / lf[f] : 100
      printf "  %6.1f%%  %3d/%-3d  %s\n", pct, lh[f], lf[f], f
      totf += lf[f]; toth += lh[f]
    }
    total = totf ? 100 * toth / totf : 0
    printf "\nCobertura da camada: %.1f%% (%d/%d linhas) | mínimo: %s%%\n", total, toth, totf, min
    if (total < min) { print "FALHOU: cobertura abaixo do mínimo."; falhou = 1 }
    else if (!falhou) { print "OK: cobertura dentro do mínimo." }
    exit falhou
  }
' "$lcov"
