module Api
  module V1
    class ClaimsController < ApplicationController
      # GET /api/v1/policyholders/:policyholder_id/claims
      #
      # NÃO IMPLEMENTADO ainda — alvo da demo da Sessão 4.
      # Anderson vai implementar esse endpoint durante plan mode + execução,
      # com paginação cursor, máscara de CPF e filtro por status.
      #
      # def index
      #   ...
      # end

      # POST /api/v1/claims
      def create
        claim = Claim.new(claim_params)

        eligibility = Claims::EvaluateEligibility.call(claim: claim)
        if eligibility.failure?
          return render json: { error: eligibility.message, code: eligibility.code },
                        status: :unprocessable_entity
        end

        if claim.save
          render json: claim_payload(claim), status: :created
        else
          render json: { errors: claim.errors.full_messages }, status: :unprocessable_entity
        end
      rescue Claims::EvaluateEligibility::EligibilityError => e
        # FIXME(débito MVP): este rescue só existe porque EvaluateEligibility
        # ainda levanta exception em vez de retornar Result. Remover quando
        # o service for unificado.
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # GET /api/v1/claims/:id
      def show
        claim = Claim.find(params[:id])
        render json: claim_payload(claim)
      end

      private

      def claim_params
        params.require(:claim).permit(
          :policy_id, :policy_coverage_id, :incident_date,
          :description, :requested_amount_cents
        )
      end

      def claim_payload(claim)
        {
          id: claim.id,
          status: claim.status,
          incident_date: claim.incident_date,
          description: claim.description,
          requested_amount: format_cents(claim.requested_amount_cents),
          payout_amount: format_cents(claim.payout_amount_cents),
          created_at: claim.created_at
        }
      end

      def format_cents(cents)
        return nil if cents.nil?

        "R$ #{format('%.2f', cents / 100.0)}"
      end
    end
  end
end
