class Policyholder < ApplicationRecord
  # Pessoa física que contrata seguro.

  has_many :policies, dependent: :restrict_with_error

  validates :name, presence: true
  validates :cpf, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :birthdate, presence: true

  # Perfil de risco usado em cálculo de prêmio.
  # low: histórico limpo, sem sinistros recorrentes
  # medium: 1-2 sinistros nos últimos 5 anos
  # high: 3+ sinistros ou perfil de alto risco (ex: corretor de auto vintage)
  enum :risk_profile, { low: "low", medium: "medium", high: "high" }, prefix: true

  def age
    return nil if birthdate.blank?

    today = Date.current
    age = today.year - birthdate.year
    age -= 1 if today < birthdate + age.years
    age
  end
end
