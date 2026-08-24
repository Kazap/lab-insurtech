# frozen_string_literal: true

class PolicyCoverage < ApplicationRecord
  # Cobertura específica dentro de uma apólice.
  # Cada apólice pode ter várias coberturas — ex: auto cobre colisão E roubo.
  #
  # Nota: a classe se chama PolicyCoverage (não Coverage) para evitar conflito
  # com a constante Coverage da stdlib do Ruby.

  self.table_name = "policy_coverages"

  belongs_to :policy
  has_many :claims, dependent: :restrict_with_error

  # auto: collision, theft, third_party
  # home: fire, theft, flood
  # life: natural_death, accidental_death, disability
  COVERAGE_TYPES = %w[
    collision theft third_party
    fire flood
    natural_death accidental_death disability
  ].freeze

  validates :coverage_type, presence: true, inclusion: { in: COVERAGE_TYPES }
  validates :max_coverage_cents, numericality: { greater_than: 0 }
  validates :deductible_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :coverage_percentage, numericality: {
    greater_than: 0, less_than_or_equal_to: 100
  }
end
