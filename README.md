# lab-insurtech — SafeCover

Aplicação **Rails 8.1 + Ruby 4.0.5** fictícia de uma insurtech brasileira, criada para o **Treinamento Kazap de Codificação Assistida por IA com Claude Code** — sessões 4 em diante.

## Cenário

SafeCover é uma insurtech brasileira fictícia, fundada em 2020 como MVP em Rails 6. Modernizada para Rails 8.1 em 2025 — mas com débito de código herdado do MVP. Domínio: seguros auto, residencial e vida para pessoas físicas.

Não é cliente real. Não é código de produção. **Use apenas para o treinamento.**

## Pré-requisitos

### Sistema operacional

- **macOS** (Intel ou Apple Silicon)
- **Linux** (Ubuntu 22.04+, Debian 12+, Fedora 39+ ou equivalente)
- **Windows** via **WSL2** (Ubuntu recomendado dentro do WSL)

### Software obrigatório

- **Ruby 4.0.5** (recomendado via `asdf install` ou `rbenv install 4.0.5`)
- **SQLite 3** (macOS/Linux já vem; WSL2 já vem em Ubuntu)
- **Bundler 4+** (instala automaticamente com Ruby 4.0.5)
- **Git 2.30+**
- **Bash 3.2+** (macOS) ou **Bash 4+** (Linux/WSL — padrão em todas as distros)
- **Claude Code** v2.1.145+ ([instalação](https://docs.claude.com/en/docs/claude-code))

### Opcional (melhora a experiência dos hooks)

Os hooks do projeto tentam usar essas ferramentas em ordem; se nenhuma estiver disponível, caem para fallback regex puro em bash.

- **python3** (vem por default em macOS recente, Ubuntu, Debian, WSL Ubuntu)
- **jq** (opcional — instalável com `brew install jq` ou `apt install jq`)
- **ripgrep (rg)** (opcional — `brew install ripgrep` ou `apt install ripgrep`); se ausente, usa `grep -r`

## Setup

```bash
git clone <repo-url> lab-insurtech
cd lab-insurtech
bin/setup
```

O script `bin/setup` faz:

1. Verifica versão do Ruby
2. `bundle install`
3. `bin/rails db:prepare` (cria DB + roda migrations + seeds)
4. Limpa logs antigos
5. Roda `bundle exec rspec --fail-fast` (validação final: tudo verde)

**Boot time esperado:** ~60s no primeiro setup, ~10s nos subsequentes.

## Estrutura

```
lab-insurtech/
├── Gemfile, .ruby-version, .tool-versions
├── CLAUDE.md                          ← contexto principal para Claude Code
├── README.md
├── .claude/
│   ├── settings.json                  ← 4 hooks configurados
│   ├── hooks/
│   │   ├── inject-context.sh
│   │   ├── validate-bash.sh
│   │   └── secret-scan.sh
│   └── skills/
│       ├── review-changes/SKILL.md
│       └── open-pr/SKILL.md
├── config/
├── db/migrate/                        ← 5 migrations
├── app/
│   ├── models/                        ← Policyholder, Policy, PolicyCoverage, Claim, PremiumPayment
│   ├── controllers/api/v1/
│   └── services/
│       ├── result.rb
│       ├── claims/
│       ├── premiums/
│       └── pii/
├── spec/
│   ├── models/
│   ├── services/
│   └── factories.rb
└── notes/
    ├── glossary.md
    ├── decisions.md
    └── legacy.md
```

## Comandos úteis

```bash
# Inicia Claude Code no projeto
claude

# Roda testes
bundle exec rspec

# Roda testes de um arquivo
bundle exec rspec spec/models/policy_spec.rb

# Roda servidor (porta 3000)
bin/rails s

# Console Rails
bin/rails c

# Reseta banco e re-popula seeds
bin/rails db:reset

# Rubocop
bundle exec rubocop
bundle exec rubocop -a  # auto-fix
```

## Vícios pedagógicos plantados

Este lab tem **11 vícios** intencionais espalhados pelo código. Eles existem como gancho pedagógico para as sessões 4-8 do treinamento. Os principais:

| # | Vício | Local | Sessão alvo |
|---|---|---|---|
| 1 | PII exposta sem máscara | `policies_controller.rb#show` | S4 (demo) |
| 2 | Regra de negócio em callback | `Claim#calculate_payout_amount` | S4 (hands-on C) |
| 3 | SQL injection | `Policy.search_by_filters` | S8 (segurança) |
| 4 | Status sem state machine | `Claim#status` | S6 (refactor) |
| 5 | Validações ausentes (vigência, cobertura) | `Claim` | S4 (hands-on B) |
| 6 | Service objects inconsistentes | `Claims::EvaluateEligibility` | S6 (refactor) |
| 7 | Lógica espalhada (`overdue?`) | `PremiumPayment` + 3 controllers | S6 (refactor) |
| 8 | Spec acoplado a callback | `claim_spec.rb` | S4 (demo) |
| 9 | Secrets em formato legível | `credentials.yml.enc` | S8 (segurança) |
| 10 | Specs sem caso de borda | `policy_spec.rb` | S4 (demo) |
| 11 | Endpoint não implementado | `claims_controller.rb#index` | S4 (demo) |

Documentação completa em `CLAUDE.md`.

## Convenções

Veja `CLAUDE.md` para padrões obrigatórios:

- Mascaramento de PII (`Pii::Masker`)
- Service objects retornando `Result`
- Valores monetários em centavos
- Specs cobrindo casos de borda

## Para o treinamento

- **Sessão 4** (Workflow de Implementação): demo + hands-on
- **Sessão 5** (MCP): conectar Claude a serviços externos
- **Sessão 6** (Refactor): pagar débito técnico
- **Sessão 7** (Plugins): plugins oficiais e custom
- **Sessão 8** (Segurança): LGPD, secrets, auditoria

Cada sessão evolui o projeto. Os vícios diminuem aula a aula.
