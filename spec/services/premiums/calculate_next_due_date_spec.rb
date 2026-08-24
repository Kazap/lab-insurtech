# frozen_string_literal: true

require "rails_helper"

RSpec.describe Premiums::CalculateNextDueDate do
  describe ".call" do
    it "retorna failure quando policy é nil" do
      result = described_class.call(policy: nil)
      expect(result).to be_failure
    end

    context "quando não há pagamentos anteriores" do
      it "retorna effective_date + 30 dias" do
        policy = create(:policy, effective_date: Date.new(2026, 1, 1))
        result = described_class.call(policy: policy)

        expect(result).to be_success
        expect(result.data).to eq(Date.new(2026, 1, 31))
      end
    end

    context "quando há pagamento confirmado" do
      it "retorna dia 5 do mês seguinte ao último pagamento" do
        policy = create(:policy)
        create(:premium_payment,
               policy: policy,
               status: "paid",
               due_date: Date.new(2026, 5, 5))

        result = described_class.call(policy: policy)
        expect(result.data).to eq(Date.new(2026, 6, 5))
      end

      it "considera apenas pagamentos com status paid" do
        policy = create(:policy)
        # Pagamento mais recente está pendente
        create(:premium_payment, policy: policy, status: "pending", due_date: Date.new(2026, 6, 5))
        # Pagamento confirmado é o anterior
        create(:premium_payment, policy: policy, status: "paid", due_date: Date.new(2026, 5, 5))

        result = described_class.call(policy: policy)
        expect(result.data).to eq(Date.new(2026, 6, 5))
      end
    end
  end
end
