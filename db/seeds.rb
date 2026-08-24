# frozen_string_literal: true

# Seeds para o lab-insurtech (SafeCover).
# Popula dados fictícios suficientes para demo S4 e hands-on.

require "faker"
require "cpf_cnpj"

Faker::Config.locale = "pt-BR"

puts "Limpando dados antigos..."
[PremiumPayment, Claim, PolicyCoverage, Policy, Policyholder].each(&:delete_all)

puts "Criando policyholders..."
policyholders = 5.times.map do
  Policyholder.create!(
    name: Faker::Name.name,
    cpf: CPF.generate(true),
    email: Faker::Internet.email,
    phone: "11#{Faker::Number.number(digits: 9)}",
    birthdate: Date.current - rand(25..60).years - rand(365).days,
    risk_profile: %w[low medium high].sample
  )
end

puts "Criando policies + coverages..."
policies = policyholders.flat_map do |ph|
  rand(1..2).times.map do
    policy_type = %w[auto home life].sample
    effective = Date.current - rand(60..400).days
    Policy.create!(
      policyholder: ph,
      policy_type: policy_type,
      status: "active",
      effective_date: effective,
      expiration_date: effective + 1.year,
      coverage_amount_cents: rand(50_000..500_000) * 100,
      monthly_premium_cents: rand(100..500) * 100
    ).tap do |policy|
      # Cada apólice tem 1-3 coberturas conforme tipo
      coverages_for_type = {
        "auto" => %w[collision theft third_party],
        "home" => %w[fire theft flood],
        "life" => %w[natural_death accidental_death disability]
      }.fetch(policy_type)

      coverages_for_type.sample(rand(1..3)).each do |ctype|
        PolicyCoverage.create!(
          policy: policy,
          coverage_type: ctype,
          max_coverage_cents: rand(10_000..200_000) * 100,
          deductible_cents: rand(0..5_000) * 100,
          coverage_percentage: [80, 90, 100].sample
        )
      end
    end
  end
end

puts "Criando claims (alguns por policy)..."
policies.each do |policy|
  rand(0..3).times do
    policy_coverage = policy.policy_coverages.sample
    next unless policy_coverage

    incident = policy.effective_date + rand(1..((policy.expiration_date - policy.effective_date).to_i - 1)).days
    Claim.create!(
      policy: policy,
      policy_coverage: policy_coverage,
      status: %w[open under_review approved paid rejected].sample,
      incident_date: incident,
      description: Faker::Lorem.sentence(word_count: 8),
      requested_amount_cents: rand(1_000..50_000) * 100
    )
  end
end

puts "Criando premium payments..."
policies.each do |policy|
  months_elapsed = ((Date.current - policy.effective_date).to_i / 30).clamp(0, 12)
  months_elapsed.times do |i|
    due = policy.effective_date + (i + 1).months
    PremiumPayment.create!(
      policy: policy,
      reference_month: due.beginning_of_month,
      due_date: due,
      amount_cents: policy.monthly_premium_cents,
      status: due < Date.current - 5.days ? "paid" : "pending",
      paid_at: (due < Date.current - 5.days ? due + 1.day : nil)
    )
  end
end

puts <<~SUMMARY

  ✓ Seeds completos.

  - #{Policyholder.count} policyholders
  - #{Policy.count} policies
  - #{PolicyCoverage.count} policy_coverages
  - #{Claim.count} claims
  - #{PremiumPayment.count} premium_payments
SUMMARY

# =============================================================================
# DEMO SESSÃO 5 — casos determinísticos de vigência
# -----------------------------------------------------------------------------
# Cole este bloco NO FIM do db/seeds.rb (depois do Faker).
#
# Por quê: o seed com Faker cria todos os claims DENTRO da vigência e todas as
# policies como "active". A demo da Sessão 5 (validação que recusa sinistro fora
# do período) precisa de casos FORA para a regra ter o que pegar.
#
# Este bloco é ADITIVO e IDEMPOTENTE (não dá delete_all, usa find_or_create_by!):
# pode rodar junto com o seed principal sem apagar os dados do Faker, e rodar
# mais de uma vez sem duplicar.
#
# Datas ancoradas relativas a HOJE, para a demo ser previsível em qualquer dia.
# A "expiração" é por DATA (expiration_date no passado), não pelo campo status —
# o enum de Policy pode não aceitar "expired", e a validação da demo olha as datas:
#   policy DEMO-ATIVA   : effective hoje-6m .. expiration hoje+6m   (vigente)
#   policy DEMO-VENCIDA : effective hoje-2a .. expiration hoje-1a   (vencida por data)
#
#   claim 1  incidente hoje-1m              -> DENTRO  da vigência    (passa)
#   claim 2  incidente hoje+9m              -> FORA (após expiration) (falha)
#   claim 3  incidente na policy vencida    -> FORA (já passou)       (falha)
#   claim 4  incidente = effective_date     -> borda exata de início  (passa)
# =============================================================================

puts "Criando casos de vigência da demo (Sessão 5)..."

demo_holder = Policyholder.find_or_create_by!(cpf: "111.111.111-11") do |p|
  p.name         = "Demo Vigência (S5)"
  p.email        = "demo.s5@safecover.test"
  p.phone        = "11999990000"
  p.birthdate    = Date.new(1990, 1, 1)
  p.risk_profile = "low"
end

hoje = Date.current

# Apólice vigente
policy_ativa = Policy.find_or_create_by!(policyholder: demo_holder, policy_type: "auto",
                                         effective_date: hoje - 6.months) do |p|
  p.status                = "active"
  p.expiration_date       = hoje + 6.months
  p.coverage_amount_cents = 5_000_000
  p.monthly_premium_cents = 25_000
end

# Apólice "vencida" por DATA (expiration_date no passado).
# Obs.: mantemos status "active" — o enum do model pode não ter "expired",
# e a validação da demo é por DATA (incident_date vs expiration_date), não por status.
policy_expirada = Policy.find_or_create_by!(policyholder: demo_holder, policy_type: "home",
                                            effective_date: hoje - 2.years) do |p|
  p.status                = "active"
  p.expiration_date       = hoje - 1.year
  p.coverage_amount_cents = 4_000_000
  p.monthly_premium_cents = 20_000
end

cobertura_ativa = PolicyCoverage.find_or_create_by!(policy: policy_ativa, coverage_type: "collision") do |c|
  c.max_coverage_cents   = 5_000_000
  c.deductible_cents     = 100_000
  c.coverage_percentage  = 100
end

cobertura_expirada = PolicyCoverage.find_or_create_by!(policy: policy_expirada, coverage_type: "fire") do |c|
  c.max_coverage_cents   = 4_000_000
  c.deductible_cents     = 120_000
  c.coverage_percentage  = 100
end

# claim 1 — DENTRO da vigência
Claim.find_or_create_by!(policy: policy_ativa, incident_date: hoje - 1.month) do |c|
  c.policy_coverage        = cobertura_ativa
  c.status                 = "open"
  c.description            = "[DEMO] Sinistro dentro da vigencia"
  c.requested_amount_cents = 450_000
end

# claim 2 — FORA (após expiration_date)
Claim.find_or_create_by!(policy: policy_ativa, incident_date: hoje + 9.months) do |c|
  c.policy_coverage        = cobertura_ativa
  c.status                 = "open"
  c.description            = "[DEMO] Sinistro apos o fim da vigencia"
  c.requested_amount_cents = 1_200_000
end

# claim 3 — FORA (apólice expirada)
Claim.find_or_create_by!(policy: policy_expirada, incident_date: hoje - 6.months) do |c|
  c.policy_coverage        = cobertura_expirada
  c.status                 = "open"
  c.description            = "[DEMO] Sinistro em apolice expirada"
  c.requested_amount_cents = 300_000
end

# claim 4 — borda exata (incident_date == effective_date)
Claim.find_or_create_by!(policy: policy_ativa, incident_date: policy_ativa.effective_date) do |c|
  c.policy_coverage        = cobertura_ativa
  c.status                 = "open"
  c.description            = "[DEMO] Sinistro na data exata de inicio (borda)"
  c.requested_amount_cents = 150_000
end

puts "  → policy vigente:  #{policy_ativa.effective_date} .. #{policy_ativa.expiration_date}"
puts "  → policy expirada: #{policy_expirada.effective_date} .. #{policy_expirada.expiration_date}"
puts "  → 4 claims da demo: dentro / fora / apólice expirada / borda"
