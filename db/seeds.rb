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
      coverages_for_type = case policy_type
                           when "auto" then %w[collision theft third_party]
                           when "home" then %w[fire theft flood]
                           when "life" then %w[natural_death accidental_death disability]
                           end

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

    incident = policy.effective_date + rand(1..(policy.expiration_date - policy.effective_date).to_i - 1).days
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
