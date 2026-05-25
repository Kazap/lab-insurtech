# Decisões arquiteturais (ADRs)

Registro de decisões técnicas tomadas no projeto SafeCover, em ordem cronológica.

---

## ADR-001 — Valores monetários em centavos (Integer)

**Data:** 2020-06 (MVP)
**Status:** Aceito, mantido

**Contexto:** O projeto começou usando `decimal(10, 2)` para valores monetários. Encontramos problemas de arredondamento em cálculos de coparticipação (`(100.00 * 0.05).round(2)` divergia entre Ruby e Postgres).

**Decisão:** Todos os valores monetários são armazenados em **centavos** (Integer). Conversão para reais (`BigDecimal` ou string formatada) acontece **apenas** na camada de apresentação (controllers, serializers).

**Consequências:**
- Cálculos exatos, sem arredondamento.
- Atributos com sufixo `_cents` (`coverage_amount_cents`, `monthly_premium_cents`).
- Camada de view precisa formatar: `"R$ #{format('%.2f', cents / 100.0)}"`.

---

## ADR-002 — Service objects retornando Result

**Data:** 2022-03
**Status:** Aceito, mas execução inconsistente (ver vício #6)

**Contexto:** Em 2022, o time decidiu padronizar lógica de negócio em service objects para tirar responsabilidades dos models. Discussão: exceptions vs Result monad?

**Decisão:** Service objects ficam em `app/services/<Domain>/<Verb>.rb` e retornam `Result.success(data:)` ou `Result.failure(message:, code:)`. **Não** levantar exceções de domínio.

**Consequências:**
- Erros são tratáveis no caller via `if result.success?`.
- Stack traces ficam reservadas para erros realmente excepcionais.
- **Problema:** alguns services ainda misturam Result com `raise`. `Claims::EvaluateEligibility` é o caso mais conhecido. Refactor pendente.

---

## ADR-003 — API-only (sem ActionView)

**Data:** 2023-01
**Status:** Aceito

**Contexto:** Frontend mobile e web são apps separados. Não precisamos de view layer no Rails.

**Decisão:** `config.api_only = true`. Sem cookies, sem sessões, sem CSRF middleware. Autenticação via JWT (a ser implementada na S7).

**Consequências:**
- Boot mais rápido.
- Menos middleware no stack.
- Não usamos `flash`, redirects, etc.

---

## ADR-004 — Migração para Rails 8.1 + Ruby 4.0

**Data:** 2025-09
**Status:** Aceito, concluído em 2025-12

**Contexto:** Rails 6 chegando ao EOL. Decisão de pular Rails 7 e ir direto para 8.1 (LTS atual).

**Decisão:** Migrar Ruby de 3.0 para 4.0.5 e Rails de 6.1 para 8.1.3.

**Consequências:**
- Ganho de performance (YJIT em produção).
- Bundler 4 — nova era de gemspecs.
- Algumas gems precisaram ser substituídas (lista em `notes/legacy.md`).
- Débito do MVP **continua** — modernizar a stack não pagou as dívidas de design.

---

## ADR-005 — SQLite em local, Postgres em produção

**Data:** 2026-01
**Status:** Em vigor

**Contexto:** Setup de Postgres local era a maior fricção para novos devs no time.

**Decisão:** Para desenvolvimento local e testes, usar SQLite 3 (file-based, zero config). Produção (fictícia para o treinamento) usa Postgres 15.

**Consequências:**
- Onboarding novo dev: `bin/setup` em <60s.
- Migrations precisam ser portáveis (sem features específicas de Postgres como JSONB, GIN indexes).
- Trade-off aceito: o lab é treinamento, não simulamos diferenças de produção.

---

## Pendências de decisão

- **State machine para `Claim#status`** — discussão em aberto. Candidatos: `aasm`, `state_machines-activerecord`, custom. Issue #42.
- **Idempotência em POST `/claims`** — atualmente não há. Sinistro duplicado é possível. Issue #51.
- **Estratégia de auditoria** — quando claim muda de status, deveria gerar evento auditável? Issue #58.
