#!/usr/bin/env bash
# PostToolUse hook — roda rubocop --autocorrect no arquivo editado pelo Claude.
# Lê o tool_input.file_path do stdin (JSON enviado pelo Claude Code) e roda
# rubocop apenas nesse arquivo. Garante:
#  - Sem reformatação em massa de arquivos não relacionados
#  - Sem race conditions com async (não precisa ser async)
#  - Skip silencioso para arquivos não-Ruby
#
# Compatível com bash 3.2+ (macOS) e bash 4+ (Linux/WSL).
# Tenta python3, depois jq, depois fallback regex puro.

set -uo pipefail

INPUT=$(cat)

# Extrai .tool_input.file_path do JSON via ferramenta disponível.
extract_file_path() {
  local json="$1"
  if command -v python3 >/dev/null 2>&1; then
    echo "$json" | python3 -c "import json, sys; d=json.load(sys.stdin); print(d.get('tool_input', {}).get('file_path', ''))" 2>/dev/null
    return
  fi
  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq -r '.tool_input.file_path // ""' 2>/dev/null
    return
  fi
  # Fallback: regex bash
  echo "$json" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1
}

FILE_PATH=$(extract_file_path "${INPUT}")

# Sem file_path → tool não tinha um arquivo (ex: MultiEdit sem path), exit limpo.
if [ -z "${FILE_PATH}" ]; then
  exit 0
fi

# Só roda em arquivos Ruby.
case "${FILE_PATH}" in
  *.rb|*.rake|Gemfile|Rakefile)
    ;;
  *)
    exit 0
    ;;
esac

# Arquivo precisa existir (Edit/Write podem falhar e PostToolUse rodar mesmo assim
# em alguns cenários).
if [ ! -f "${FILE_PATH}" ]; then
  exit 0
fi

# Roda rubocop só no arquivo editado.
# Saída do rubocop é silenciada — só interessa para o aluno quando há erro real.
bundle exec rubocop --autocorrect "${FILE_PATH}" >/dev/null 2>&1

# Sempre exit 0 — formatação é cosmética, não bloqueia o fluxo do Claude.
exit 0
