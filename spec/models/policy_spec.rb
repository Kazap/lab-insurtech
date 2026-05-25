require "rails_helper"

RSpec.describe Policy do
  describe "validations" do
    it { is_expected.to validate_presence_of(:effective_date) }
    it { is_expected.to validate_presence_of(:expiration_date) }
    it { is_expected.to validate_numericality_of(:coverage_amount_cents).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:monthly_premium_cents).is_greater_than(0) }

    it "rejeita expiration anterior a effective" do
      policy = build(:policy, effective_date: Date.current, expiration_date: Date.current - 1.day)
      expect(policy).not_to be_valid
      expect(policy.errors[:expiration_date]).to include("must be after effective_date")
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:policyholder) }
    it { is_expected.to have_many(:policy_coverages).dependent(:destroy) }
    it { is_expected.to have_many(:claims).dependent(:restrict_with_error) }
  end

  describe "#in_effect?" do
    let(:policy) do
      build(:policy,
        effective_date: 1.month.ago.to_date,
        expiration_date: 11.months.from_now.to_date,
        status: "active")
    end

    it "retorna true para apólice ativa dentro da vigência" do
      expect(policy.in_effect?).to be(true)
    end

    it "retorna false quando suspensa" do
      policy.status = "suspended"
      expect(policy.in_effect?).to be(false)
    end

    it "retorna false após expiration_date" do
      expect(policy.in_effect?(policy.expiration_date + 1.day)).to be(false)
    end

    it "retorna false antes do effective_date" do
      expect(policy.in_effect?(policy.effective_date - 1.day)).to be(false)
    end
  end

  describe ".search_by_filters" do
    # TODO(débito MVP): estes testes apenas demonstram funcionalidade.
    # NÃO cobrem o caso de SQL injection — a fragilidade segue lá.
    # Quando o método for refatorado para usar placeholders, adicionar:
    #   it "não permite SQL injection no filtro cpf"
    it "filtra por cpf" do
      ph = create(:policyholder, cpf: "12345678901")
      policy = create(:policy, policyholder: ph)
      _other = create(:policy)

      expect(described_class.search_by_filters(cpf: "12345678901")).to contain_exactly(policy)
    end

    it "filtra por status" do
      active = create(:policy, status: "active")
      _suspended = create(:policy, status: "suspended")

      result = described_class.search_by_filters(status: "active")
      expect(result).to include(active)
    end
  end
end
