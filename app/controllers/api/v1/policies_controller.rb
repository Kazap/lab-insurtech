# frozen_string_literal: true

module Api
  module V1
    class PoliciesController < ApplicationController
      # GET /api/v1/policies/:id
      #
      # FIXME(débito MVP): expõe CPF, email completo e telefone do policyholder.
      # Veja CLAUDE.md seção "PII e LGPD" — deve usar Pii::Masker.
      # Issue #38 no Jira.
      def show
        policy = Policy.includes(:policyholder, :policy_coverages).find(params.expect(:id))

        render json: {
          id: policy.id,
          policy_type: policy.policy_type,
          status: policy.status,
          effective_date: policy.effective_date,
          expiration_date: policy.expiration_date,
          coverage_amount: format_cents(policy.coverage_amount_cents),
          monthly_premium: format_cents(policy.monthly_premium_cents),
          policyholder: policy.policyholder.as_json, # <-- PII exposta aqui
          coverages: policy.policy_coverages.map { |c| coverage_payload(c) }
        }
      end

      private

      def coverage_payload(policy_coverage)
        {
          id: policy_coverage.id,
          coverage_type: policy_coverage.coverage_type,
          max_coverage: format_cents(policy_coverage.max_coverage_cents),
          deductible: format_cents(policy_coverage.deductible_cents),
          coverage_percentage: policy_coverage.coverage_percentage
        }
      end

      def format_cents(cents)
        return nil if cents.nil?

        "R$ #{format("%.2f", cents / 100.0)}"
      end
    end
  end
end
