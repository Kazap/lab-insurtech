module Claims
  # Avalia se um claim é elegível para análise.
  #
  # FIXME(débito MVP): este service mistura dois estilos de retorno —
  # alguns paths levantam exceção (EligibilityError), outros retornam
  # Result.failure. Veja convenção em CLAUDE.md: sempre Result.
  #
  # Refactor pendente: unificar tudo via Result.
  #
  class EvaluateEligibility
    class EligibilityError < StandardError; end

    def self.call(claim:)
      # Estilo Result (correto)
      return Result.failure(message: "Claim is nil") if claim.nil?
      return Result.failure(message: "Policy is required") if claim.policy.blank?

      # Estilo exception (vício pedagógico - inconsistente)
      raise EligibilityError, "Policy not active" unless claim.policy.status_active?

      # Mais um Result
      if claim.incident_date && claim.policy.expiration_date
        if claim.incident_date > claim.policy.expiration_date
          return Result.failure(message: "Incident after policy expiration", code: "expired_policy")
        end
      end

      Result.success(data: claim)
    end
  end
end
