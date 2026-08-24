# frozen_string_literal: true

module Premiums
  # Calcula próxima data de vencimento de prêmio para uma apólice.
  # Regra: dia 5 do mês seguinte ao último pagamento confirmado.
  # Se nunca houve pagamento, usa effective_date da apólice + 30 dias.
  #
  class CalculateNextDueDate
    def self.call(policy:)
      return Result.failure(message: "Policy is required") if policy.nil?

      last_paid = policy.premium_payments.status_paid.order(due_date: :desc).first

      next_date = if last_paid
                    last_paid.due_date.next_month.change(day: 5)
                  else
                    policy.effective_date + 30.days
                  end

      Result.success(data: next_date)
    end
  end
end
