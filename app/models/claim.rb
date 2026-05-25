class Claim < ApplicationRecord
  # Sinistro: evento que dispara cobertura da apólice.

  belongs_to :policy
  belongs_to :policy_coverage

  # status possíveis: open → under_review → approved → paid
  #                                                  → rejected
  #
  # FIXME(débito MVP): sem state machine — campo é string livre.
  # Permite `claim.update(status: "paid")` direto sem passar por approved.
  # Migrar para AASM ou state_machines-activerecord.
  VALID_STATUSES = %w[open under_review approved paid rejected].freeze

  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validates :incident_date, presence: true
  validates :description, presence: true
  validates :requested_amount_cents, numericality: { greater_than: 0 }

  # TODO(débito MVP): validações ausentes.
  # 1. incident_date deveria estar dentro da vigência da apólice
  # 2. coverage_type do claim deveria estar entre as coverages contratadas
  # 3. requested_amount não deveria exceder coverage_amount da apólice
  # Veja issue #42 no Jira interno.

  # FIXME(débito MVP): regra de negócio em callback.
  # Cálculo de indenização está acoplado ao before_save, dificultando teste isolado
  # e impossibilitando reuso (ex: simular indenização antes de criar o claim).
  # Extrair para Claims::CalculatePayoutAmount.
  before_save :calculate_payout_amount, if: :should_calculate_payout?

  scope :recent_first, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) if status.present? }

  private

  def should_calculate_payout?
    requested_amount_cents_changed? || status_changed?
  end

  def calculate_payout_amount
    return if policy_coverage.blank? || policy.blank?

    # Aplica franquia
    after_deductible = requested_amount_cents - policy_coverage.deductible_cents
    return self.payout_amount_cents = 0 if after_deductible <= 0

    # Aplica percentual de cobertura
    proportional = (after_deductible * policy_coverage.coverage_percentage / 100.0).to_i

    # Limita ao máximo da cobertura e ao valor segurado da apólice
    self.payout_amount_cents = [
      proportional,
      policy_coverage.max_coverage_cents,
      policy.coverage_amount_cents
    ].min
  end
end
