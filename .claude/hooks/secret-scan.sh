#!/usr/bin/env bash
# PreToolUse hook para Edit/Write — bloqueia gravação de secrets e PII no código.
# Recebe JSON via stdin, decide via exit code.
#
# Padrões verificados:
#   - AWS Access Key ID:    AKIA[0-9A-Z]{16}
#   - OpenAI API key:       sk-[A-Za-z0-9]{20,}
#   - Anthropic API key:    sk-ant-[A-Za-z0-9_-]{20,}
#   - GitHub PAT:           ghp_[A-Za-z0-9]{36}
#   - Stripe live key:      sk_live_[A-Za-z0-9]{20,}
#   - CPF formatado em código (.rb fora de spec/seeds/test)
#
# Compatível com bash 3.2+ (macOS) e bash 4+ (Linux/WSL).
# Tenta python3, depois jq, depois fallback regex puro.

set -uo pipefail

INPUT=$(cat)

# Extrai um campo do tool_input via ferramenta disponível.
# Uso: extract_field <json> <field_name>
extract_field() {
  local json="$1"
  local field="$2"

  if command -v python3 >/dev/null 2>&1; then
    echo "$json" | python3 -c "
import json, sys
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
# Tenta o campo solicitado; se for 'content', também tenta 'new_string' (MultiEdit)
val = ti.get('$field', '')
if not val and '$field' == 'content':
    val = ti.get('new_string', '')
print(val)
" 2>/dev/null
    return
  fi

  if command -v jq >/dev/null 2>&1; then
    if [ "$field" = "content" ]; then
      echo "$json" | jq -r '.tool_input.content // .tool_input.new_string // ""' 2>/dev/null
    else
      echo "$json" | jq -r ".tool_input.$field // \"\"" 2>/dev/null
    fi
    return
  fi

  # Fallback regex bash
  echo "$json" | sed -n "s/.*\"$field\"[[:space:]]*:[[:space:]]*\"\(\(\\\\.\|[^\"\\\\]\)*\)\".*/\1/p" | head -1
}

FILE_PATH=$(extract_field "${INPUT}" "file_path")
CONTENT=$(extract_field "${INPUT}" "content")

if [ -z "${FILE_PATH}" ]; then
  exit 0
fi

# Pula verificação para alguns paths
case "${FILE_PATH}" in
  */node_modules/*|*/.git/*|*/tmp/*|*/log/*|*/storage/*)
    exit 0
    ;;
esac

# Verifica padrões de secrets
check_pattern() {
  local pattern="$1"
  local label="$2"
  if echo "${CONTENT}" | grep -qE "${pattern}"; then
    echo "Bloqueado por secret-scan.sh: detectado padrão '${label}' em ${FILE_PATH}" >&2
    echo "Verifique se está usando credentials.yml.enc ou variável de ambiente." >&2
    return 1
  fi
  return 0
}

check_pattern "AKIA[0-9A-Z]{16}"           "AWS Access Key ID"           || exit 2
check_pattern "sk-[A-Za-z0-9]{20,}"        "OpenAI API key"              || exit 2
check_pattern "sk-ant-[A-Za-z0-9_-]{20,}"  "Anthropic API key"           || exit 2
check_pattern "ghp_[A-Za-z0-9]{36}"        "GitHub Personal Access Token" || exit 2
check_pattern "sk_live_[A-Za-z0-9]{20,}"   "Stripe live key"             || exit 2

# CPF formatado em arquivo de código (não em specs nem seeds — esses usam Faker/dados fake)
# Usa case + glob em vez de [[ =~ ]] para máxima portabilidade
case "${FILE_PATH}" in
  *.rb)
    case "${FILE_PATH}" in
      *spec*|*seeds*|*test*)
        # Permitido em specs/seeds/test
        ;;
      *)
        # Arquivo de código produção — bloqueia CPF formatado
        if echo "${CONTENT}" | grep -qE "[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}"; then
          echo "Bloqueado por secret-scan.sh: CPF formatado em arquivo de código (${FILE_PATH})" >&2
          echo "Se for dado de teste, use spec/factories ou Faker. Se for dado real, NUNCA commitar." >&2
          exit 2
        fi
        ;;
    esac
    ;;
esac

exit 0
