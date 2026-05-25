require "rails_helper"

RSpec.describe Claim do
  describe "validations" do
    it { is_expected.to validate_presence_of(:incident_date) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_inclusion_of(:status).in_array(described_class::VALID_STATUSES) }
    it { is_expected.to validate_numericality_of(:requested_amount_cents).is_greater_than(0) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:policy) }
    it { is_expected.to belong_to(:policy_coverage) }
  end

  # FIXME(débito MVP): testes a seguir são acoplados ao callback before_save.
  # Estamos testando o efeito colateral de :calculate_payout_amount em vez
  # de testar uma chamada isolada à lógica de cálculo.
  # Quando Claims::CalculatePayoutAmount for extraído (S4 hands-on feature C),
  # mover esses testes para o spec do service object.
  describe "callback :calculate_payout_amount" do
    let(:policy_coverage) do
      create(:policy_coverage,
        max_coverage_cents: 50_000_00,
        deductible_cents: 1_000_00,
        coverage_percentage: 100)
    end

    let(:policy) { policy_coverage.policy }

    it "subtrai franquia do valor solicitado" do
      claim = build(:claim,
        policy: policy,
        policy_coverage: policy_coverage,
        requested_amount_cents: 10_000_00)

      claim.save!
      # 10.000 - 1.000 = 9.000 (100% de cobertura)
      expect(claim.payout_amount_cents).to eq(9_000_00)
    end

    it "aplica percentual de cobertura" do
      policy_coverage.update!(coverage_percentage: 80)
      claim = build(:claim,
        policy: policy,
        policy_coverage: policy_coverage,
        requested_amount_cents: 10_000_00)

      claim.save!
      # (10.000 - 1.000) * 0.8 = 7.200
      expect(claim.payout_amount_cents).to eq(7_200_00)
    end

    it "limita ao max_coverage da cobertura" do
      policy_coverage.update!(max_coverage_cents: 5_000_00)
      claim = build(:claim,
        policy: policy,
        policy_coverage: policy_coverage,
        requested_amount_cents: 100_000_00)

      claim.save!
      expect(claim.payout_amount_cents).to eq(5_000_00)
    end

    it "retorna zero quando valor solicitado é menor que franquia" do
      claim = build(:claim,
        policy: policy,
        policy_coverage: policy_coverage,
        requested_amount_cents: 500_00)  # menor que deductible 1.000

      claim.save!
      expect(claim.payout_amount_cents).to eq(0)
    end
  end

  describe "scopes" do
    describe ".recent_first" do
      it "ordena por created_at decrescente" do
        older = create(:claim, created_at: 2.days.ago)
        newer = create(:claim, created_at: 1.day.ago)

        expect(described_class.recent_first).to eq([newer, older])
      end
    end

    describe ".by_status" do
      it "filtra por status quando presente" do
        open_claim = create(:claim, status: "open")
        _approved = create(:claim, status: "approved")

        expect(described_class.by_status("open")).to contain_exactly(open_claim)
      end

      it "retorna tudo quando status é blank" do
        create(:claim, status: "open")
        create(:claim, status: "approved")

        expect(described_class.by_status(nil).count).to eq(2)
      end
    end
  end
end
