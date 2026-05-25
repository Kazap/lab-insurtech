---
name: review-changes
description: Revisão estruturada das próprias mudanças do branch atual antes de abrir PR. Analisa diff em 4 dimensões — rule-out-of-place, pii-not-masked, missing-test, convention. Use no fim do ciclo plan → execução → hooks → review.
disable-model-invocation: true
model: claude-sonnet-4-6
effort: high
allowed-tools: "Read Grep Glob Bash(git diff:*) Bash(git log:*) Bash(git branch:*) Bash(git rev-parse:*) Bash(git symbolic-ref:*)"
---

# Revisão das mudanças do branch atual

## Contexto

Branch atual:
!`git branch --show-current`

Branch base detectada (main ou master):
!`git rev-parse --verify main >/dev/null 2>&1 && echo "main" || (git rev-parse --verify master >/dev/null 2>&1 && echo "master") || echo "(nenhuma branch base encontrada — usando HEAD~1)"`

Diff em relação à branch base (resumo):
!`BASE=$(git rev-parse --verify main >/dev/null 2>&1 && echo "main" || (git rev-parse --verify master >/dev/null 2>&1 && echo "master") || echo "HEAD~1"); git diff "$BASE"...HEAD --stat`

Diff completo:
!`BASE=$(git rev-parse --verify main >/dev/null 2>&1 && echo "main" || (git rev-parse --verify master >/dev/null 2>&1 && echo "master") || echo "HEAD~1"); git diff "$BASE"...HEAD`

## Tarefa

Analise as mudanças deste branch em **4 dimensões**. Para cada dimensão, indique:

- ✓ se está OK
- ⚠ se há problema, com **arquivo:linha** e descrição curta

### 1. Regra fora do lugar

Verifique se há lógica de negócio em local errado, segundo as convenções do projeto (veja `CLAUDE.md`):

- Regra em `before_save` / `after_save` callback → deveria estar em service object
- Cálculo monetário no controller → deveria estar no model ou service
- Validação de invariante de domínio inline → deveria estar como validação do model

### 2. PII não mascarada

Verifique se há exposição de dados pessoais sem `Pii::Masker`:

- `cpf`, `email` ou `phone` retornado em response JSON sem máscara
- `cpf` ou `email` logado via `Rails.logger.info`
- Atributos como `as_json` ou `to_json` sem `except:` para PII

Convenções de mascaramento estão em `CLAUDE.md` seção "PII e LGPD".

### 3. Teste ausente

Verifique se há mudança em código sem teste correspondente:

- Novo método público sem spec
- Novo endpoint sem spec de request
- Novo serviço sem spec
- Mudança em validação sem spec de caso de borda (valor zero, nulo, limite)

**Importante:** specs **acoplados a callback** (como `claim_spec.rb` atualmente) **não contam** como cobertura adequada — sinalize quando ver isso.

### 4. Convenção

Verifique se as mudanças seguem padrões do projeto:

- Service objects retornam `Result.success` / `Result.failure` (nunca `raise`)
- Valores monetários em centavos (Integer), não Float
- Nomes em inglês para identificadores
- Comentários e TODOs em PT-BR
- Migrations reversíveis
- Sem `where("string interpolada #{var}")` — sempre placeholders

## Formato de saída

Apresente em formato de tabela:

| Dimensão | Status | Detalhe |
|---|---|---|
| Regra fora do lugar | ✓ ou ⚠ | arquivo:linha — descrição |
| PII não mascarada | ✓ ou ⚠ | arquivo:linha — descrição |
| Teste ausente | ✓ ou ⚠ | arquivo:linha — descrição |
| Convenção | ✓ ou ⚠ | arquivo:linha — descrição |

Se tudo OK, finalize com: **Tudo limpo. Pronto para `/open-pr`.**

Se houver problemas, finalize com: **Há ajustes recomendados. Volte ao plan mode para corrigir antes de abrir PR.**
