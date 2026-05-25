#!/usr/bin/env bash
# SessionStart hook — imprime estado do projeto.
# Saída em stdout vira contexto do Claude.
#
# Compatível com bash 3.2+ (macOS) e bash 4+ (Linux/WSL).
# Dependências: git (obrigatório), rg ou grep (qualquer um).

set -euo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}"

echo "## Estado do projeto"
echo ""

# Branch
if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
  echo "**Branch:** \`${branch}\`"
fi

# Dirty count
# Importante: wc -l retorna com espaços em macOS, sem em Linux.
# tr -d ' ' normaliza para comparação numérica robusta.
if dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' '); then
  if [ "${dirty}" -gt 0 ]; then
    echo "**Arquivos modificados:** ${dirty}"
  else
    echo "**Working tree:** limpo"
  fi
fi

# Último commit
if last=$(git log -1 --pretty=format:'%h %s' 2>/dev/null); then
  echo "**Último commit:** ${last}"
fi

echo ""

# TODOs / FIXMEs ativos (top 5)
# Prefere ripgrep (rg) se disponível; fallback para grep (universal).
echo "**TODOs e FIXMEs ativos no código:**"
echo ""
if command -v rg >/dev/null 2>&1; then
  rg -n --no-heading "(TODO|FIXME)" app/ config/ 2>/dev/null | head -5 | sed 's/^/- /' || echo "- (nenhum encontrado)"
else
  grep -rn "TODO\|FIXME" app/ config/ 2>/dev/null | head -5 | sed 's/^/- /' || echo "- (nenhum encontrado)"
fi

echo ""

# Estado dos testes (cache do RSpec)
if [ -f spec/examples.txt ]; then
  passed=$(grep -c "passed" spec/examples.txt 2>/dev/null | tr -d ' ' || echo "0")
  failed=$(grep -c "failed" spec/examples.txt 2>/dev/null | tr -d ' ' || echo "0")
  if [ "${failed}" -gt 0 ]; then
    echo "**Última execução de RSpec:** ${passed} passou(aram), ${failed} falharam"
  else
    echo "**Última execução de RSpec:** ${passed} passou(aram) ✓"
  fi
fi

exit 0
