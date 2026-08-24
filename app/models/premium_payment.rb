# frozen_string_literal: true

class PremiumPayment < ApplicationRecord
  # Pagamento mensal do prêmio da apólice.

  belongs_to :policy

  # pending: aguarda pagamento; paid: confirmado; overdue: atrasado.
  enum :status, { pending: "pending", paid: "paid", overdue: "overdue" }, prefix: true

  validates :reference_month, presence: true
  validates :due_date, presence: true
  validates :amount_cents, numericality: { greater_than: 0 }

  # TODO(débito MVP): este método é calculado inline em 3 controllers diferentes:
  #   - PoliciesController#show
  #   - PolicyholdersController#show
  #   - PremiumPaymentsController#index (futuro)
  # Centralizar lógica num service ou query object.
  def overdue?
    return false if status_paid?

    Date.current > due_date
  end
end
