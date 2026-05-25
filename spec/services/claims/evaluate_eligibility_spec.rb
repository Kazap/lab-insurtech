require "rails_helper"

RSpec.describe Claims::EvaluateEligibility do
  # FIXME(débito MVP): este spec evidencia o vício de retornos inconsistentes
  # do service. Alguns paths retornam Result, outros levantam EligibilityError.
  # Quando o service for unificado, todos os testes devem usar pattern Result.
  describe ".call" do
    context "retornos via Result (caminho correto)" do
      it "retorna failure quando claim é nil" do
        result = described_class.call(claim: nil)
        expect(result).to be_failure
        expect(result.message).to match(/nil/i)
      end

      it "retorna failure quando incident_date é após expiration" do
        policy = create(:policy, expiration_date: Date.current - 30.days, effective_date: Date.current - 1.year)
        claim = build(:claim, policy: policy, incident_date: Date.current)

        result = described_class.call(claim: claim)
        expect(result).to be_failure
        expect(result.code).to eq("expired_policy")
      end

      it "retorna success quando tudo está OK" do
        policy = create(:policy,
          status: "active",
          effective_date: 1.month.ago.to_date,
          expiration_date: 11.months.from_now.to_date)
        claim = build(:claim, policy: policy, incident_date: Date.current)

        result = described_class.call(claim: claim)
        expect(result).to be_success
      end
    end

    context "retornos via exception (vício pedagógico)" do
      it "levanta EligibilityError quando policy está suspended" do
        policy = create(:policy, status: "suspended")
        claim = build(:claim, policy: policy)

        expect {
          described_class.call(claim: claim)
        }.to raise_error(described_class::EligibilityError, /not active/)
      end
    end
  end
end
