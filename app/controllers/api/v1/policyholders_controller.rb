module Api
  module V1
    class PolicyholdersController < ApplicationController
      # GET /api/v1/policyholders/:id
      #
      # Endpoint correto: usa Pii::Masker para dados sensíveis.
      def show
        policyholder = Policyholder.find(params[:id])

        render json: {
          id: policyholder.id,
          name: policyholder.name,
          cpf: Pii::Masker.mask_cpf(policyholder.cpf),
          email: Pii::Masker.mask_email(policyholder.email),
          phone: Pii::Masker.mask_phone(policyholder.phone),
          age: policyholder.age,
          risk_profile: policyholder.risk_profile,
          active_policies_count: policyholder.policies.status_active.count
        }
      end
    end
  end
end
