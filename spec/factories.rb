require "cpf_cnpj"

FactoryBot.define do
  factory :policyholder do
    name { Faker::Name.name }
    cpf { CPF.generate(true) }
    sequence(:email) { |n| "user#{n}@example.com" }
    phone { "11987654321" }
    birthdate { 30.years.ago }
    risk_profile { "medium" }
  end

  factory :policy do
    policyholder
    policy_type { "auto" }
    status { "active" }
    effective_date { 1.month.ago.to_date }
    expiration_date { 11.months.from_now.to_date }
    coverage_amount_cents { 100_000_00 }
    monthly_premium_cents { 250_00 }
  end

  factory :policy_coverage do
    policy
    coverage_type { "collision" }
    max_coverage_cents { 50_000_00 }
    deductible_cents { 1_000_00 }
    coverage_percentage { 100 }
  end

  factory :claim do
    policy
    policy_coverage { association(:policy_coverage, policy: policy) }
    status { "open" }
    incident_date { Date.current - 5.days }
    description { "Colisão na Av. Paulista" }
    requested_amount_cents { 10_000_00 }
  end

  factory :premium_payment do
    policy
    reference_month { Date.current.beginning_of_month }
    due_date { Date.current + 5.days }
    amount_cents { 250_00 }
    status { "pending" }
  end
end
