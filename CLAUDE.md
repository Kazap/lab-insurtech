# SafeCover — Convenções do projeto

Insurtech brasileira fictícia para o **Treinamento Kazap de Codificação Assistida por IA com Claude Code**. Não é cliente real, não é código de produção.

## Cenário

SafeCover é uma insurtech brasileira fundada em 2020 como MVP, modernizada para Rails 8.1 em 2025. Atende seguros de auto, residencial e vida para pessoas físicas. O time atravessou a migração de stack mas trouxe vícios herdados do MVP que ainda precisam ser pagos.

## Stack

- Ruby 4.0.5
- Rails 8.1.x (API-only)
- SQLite 3 (local), Postgres 15 (produção fictícia)
- RSpec, FactoryBot, Faker
- Rubocop + rubocop-rails + rubocop-rspec

## Domínio

- **Policyholder** — pessoa física que contrata seguro. Tem `cpf`, `email`, `phone`, `birthdate`, `risk_profile`.
- **Policy** — apólice. Pertence a um policyholder. Tem `policy_type` (auto/home/life), `status` (active/suspended/canceled), `effective_date`, `expiration_date`, `coverage_amount_cents`, `monthly_premium_cents`.
- **PolicyCoverage** — cobertura específica dentro da apólice. Tem `coverage_type` (collision, theft, fire, etc), `max_coverage_cents`, `deductible_cents`, `coverage_percentage`. Nome explícito (em vez de só `Coverage`) para não colidir com a constante `Coverage` da stdlib do Ruby.
- **Claim** — sinistro. Tem `policy`, `coverage`, `status` (open/under_review/approved/paid/rejected), `incident_date`, `requested_amount_cents`, `payout_amount_cents`.
- **PremiumPayment** — pagamento mensal do prêmio. Tem `policy`, `reference_month`, `due_date`, `amount_cents`, `status` (pending/paid/overdue).

## Padrões obrigatórios

### PII e LGPD

**Nunca** expor `cpf`, `email` completo ou `phone` em respostas API ou logs — sempre mascarar.

- CPF: `***.***.***-89` (mostra só últimos 2 dígitos)
- Email: `j***@gmail.com` (primeiro caractere + domínio)
- Phone: `(11) ****-1234` (DDD + últimos 4 dígitos)

Helper: `Pii::Masker.mask_cpf(cpf)`, `Pii::Masker.mask_email(email)`, `Pii::Masker.mask_phone(phone)`.

**Exemplo de endpoint correto:**

```ruby
# app/controllers/api/v1/policyholders_controller.rb
render json: {
  id: policyholder.id,
  name: policyholder.name,
  cpf: Pii::Masker.mask_cpf(policyholder.cpf),
  email: Pii::Masker.mask_email(policyholder.email),
  phone: Pii::Masker.mask_phone(policyholder.phone)
}
```

### Service objects

Em `app/services/<Domain>/<Verb>.rb`. Sempre retornar `Result.success(data: ...)` ou `Result.failure(message:, code:)`. **Nunca** levantar exceções de domínio — apenas erros realmente excepcionais (DB down, etc).

**Exemplo correto:**

```ruby
module Claims
  class EvaluateEligibility
    def self.call(claim:)
      return Result.failure(message: "Policy not in effect") unless claim.policy.in_effect?

      Result.success(data: claim)
    end
  end
end
```

### Specs

- Cobrir caso feliz + pelo menos 2 casos de borda
- **Não testar implementação interna** (callbacks, métodos privados) — teste o comportamento, não o como
- Usar FactoryBot — nunca `create!` direto com hash de atributos
- Para services, testar `Result.success?` / `Result.failure?` + `.data` / `.message`

### Valores monetários

Sempre em centavos (`Integer`). Nunca `Float` ou `BigDecimal` no banco. Conversão para reais apenas na camada de apresentação:

```ruby
"R$ #{format("%.2f", cents / 100.0)}"
```

### Datas e vigências

`Policy#in_effect?` deve ser usado para validar se uma apólice pode aceitar claims. A regra é:

```
effective_date <= incident_date <= expiration_date  AND  status == "active"
```

## Vícios conhecidos (débito pago aos poucos)

Os seguintes pontos têm `FIXME(débito MVP)` no código:

1. `Api::V1::PoliciesController#show` expõe PII do policyholder sem máscara
2. `Claim.before_save :calculate_payout_amount` — regra de negócio em callback
3. `Policy.search_by_filters` — concatena strings em `where`, vulnerável a SQL injection
4. `Claim#status` sem state machine — string livre
5. Validações ausentes em `Claim`:
   - `incident_date` não validado contra vigência da apólice
   - `coverage_type` do claim não validado contra coberturas da apólice
   - `requested_amount_cents` pode exceder `coverage_amount_cents`
6. `Claims::EvaluateEligibility` mistura `Result` e `raise EligibilityError`
7. `PremiumPayment#overdue?` calculado inline em 3 controllers
8. `spec/models/claim_spec.rb` acoplado ao callback `calculate_payout_amount`
9. `config/credentials.yml.enc` em formato legível (deveria estar encriptado)
10. `apolice_spec.rb` sem casos de borda críticos

Quando trabalhar nesses arquivos, considere se o débito do ponto correspondente pode ser pago como parte da mudança — mas **não force**. Cada PR tem escopo limitado; refactor amplo deve ter PR próprio.

## Restrições absolutas

- Nunca expor PII sem máscara em logs ou respostas
- Nunca alterar `db/schema.rb` diretamente — sempre via migration reversível
- Nunca commitar sem `bundle exec rspec` verde
- Nunca usar `where("#{var}")` — sempre placeholders (`where("col = ?", var)`)
- Sempre incluir teste para mudança em model ou service

## Convenções de Git

- Branches: `feature/<descricao>`, `fix/<descricao>`, `refactor/<descricao>`
- Para o treinamento: `treinamento/<seu-nome>`
- Commits curtos, imperativos: "adiciona endpoint X", "corrige validação Y"
- PRs com descrição padronizada (a skill `/open-pr` ajuda com isso)

## Referências internas

- `notes/glossary.md` — termos do domínio insurtech
- `notes/decisions.md` — ADRs (decisões arquiteturais históricas)
- `notes/legacy.md` — contexto do MVP de 2020
