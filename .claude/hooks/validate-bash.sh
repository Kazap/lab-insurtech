#!/usr/bin/env bash
# PreToolUse hook para Bash — bloqueia comandos perigosos.
# Recebe JSON via stdin, decide via exit code.
#
# Semântica:
#   exit 0  → libera
#   exit 2  → BLOQUEIA (stderr volta pro Claude como erro)
#   exit 1  → non-blocking error (operação prossegue, hook em si falhou)
#
# Compatível com bash 3.2+ (macOS) e bash 4+ (Linux/WSL).
# Tenta usar python3, depois jq, depois fallback regex puro.

set -uo pipefail

INPUT=$(cat)

# Extrai .tool_input.command do JSON usando ferramenta disponível.
# Ordem: python3 → jq → regex bash (fallback).
extract_command() {
  local json="$1"

  if command -v python3 >/dev/null 2>&1; then
    echo "$json" | python3 -c "import json, sys; data=json.load(sys.stdin); print(data.get('tool_input', {}).get('command', ''))" 2>/dev/null
    return
  fi

  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq -r '.tool_input.command // ""' 2>/dev/null
    return
  fi

  # Fallback: regex bash. Procura "command":"..." dentro de tool_input.
  # Pega tudo entre as primeiras aspas após "command":
  echo "$json" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\(\\.\|[^"\\]\)*\)".*/\1/p' | head -1
}

CMD=$(extract_command "${INPUT}")

if [ -z "${CMD}" ]; then
  # Não conseguiu extrair — libera com aviso interno (exit 1 = non-blocking)
  echo "warning: validate-bash.sh não conseguiu parsear o comando" >&2
  exit 1
fi

# Padrões PERIGOSOS — bloquear com exit 2
BLOCKED_PATTERNS=(
  "rm -rf /"
  "rm -rf /\*"
  "rm -rf ~"
  "rm -rf \$HOME"
  "DROP TABLE"
  "DROP DATABASE"
  "TRUNCATE TABLE"
  "git push --force"
  "git push -f"
  "git reset --hard origin/main"
  ":(){:|:&};:"
  "dd if=/dev/zero"
  "mkfs"
  "> /dev/sda"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "${CMD}" | grep -qF "${pattern}"; then
    echo "Bloqueado pelo hook validate-bash.sh: comando contém padrão perigoso '${pattern}'" >&2
    echo "Comando rejeitado: ${CMD}" >&2
    exit 2
  fi
done

# git push --force <main|master> (regex POSIX, sem \b)
# Funciona em GNU grep (Linux) e BSD grep (macOS)
if echo "${CMD}" | grep -qE "git +push.*--force.*(main|master)( |$)"; then
  echo "Bloqueado: git push --force em branch protegida (main/master)" >&2
  exit 2
fi

exit 0
