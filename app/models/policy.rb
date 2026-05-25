class Policy < ApplicationRecord
  # Apólice de seguro. Contrato entre policyholder e SafeCover.

  belongs_to :policyholder
  has_many :policy_coverages, dependent: :destroy
  has_many :claims, dependent: :restrict_with_error
  has_many :premium_payments, dependent: :destroy

  # auto, home, life
  enum :policy_type, { auto: "auto", home: "home", life: "life" }, prefix: true

  # active: vigente; suspended: pagamento atrasado; canceled: encerrada.
  enum :status, { active: "active", suspended: "suspended", canceled: "canceled" }, prefix: true

  validates :effective_date, presence: true
  validates :expiration_date, presence: true
  validates :coverage_amount_cents, numericality: { greater_than: 0 }
  validates :monthly_premium_cents, numericality: { greater_than: 0 }

  validate :expiration_after_effective

  # Apólice está dentro do período de vigência hoje?
  def in_effect?(on_date = Date.current)
    return false unless status_active?

    effective_date <= on_date && on_date <= expiration_date
  end

  # FIXME(débito MVP): SQL injection clássico. Refatorar para usar placeholders.
  # Foi escrito no MVP de 2020 quando o time não conhecia ActiveRecord direito.
  # Tem teste passando hoje, mas é vulnerável.
  def self.search_by_filters(filters = {})
    conditions = []
    if filters[:cpf].present?
      conditions << "policyholders.cpf = '#{filters[:cpf]}'"
    end
    if filters[:status].present?
      conditions << "policies.status = '#{filters[:status]}'"
    end

    joins(:policyholder).where(conditions.join(" AND "))
  end

  private

  def expiration_after_effective
    return if effective_date.blank? || expiration_date.blank?
    return if expiration_date > effective_date

    errors.add(:expiration_date, "must be after effective_date")
  end
end
