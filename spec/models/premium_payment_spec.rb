# frozen_string_literal: true

require "rails_helper"

RSpec.describe PremiumPayment do
  describe "validations" do
    it { is_expected.to validate_presence_of(:reference_month) }
    it { is_expected.to validate_presence_of(:due_date) }
    it { is_expected.to validate_numericality_of(:amount_cents).is_greater_than(0) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:policy) }
  end

  describe "#overdue?" do
    it "retorna true quando due_date passou e status não é paid" do
      payment = build(:premium_payment, due_date: Date.current - 5.days, status: "pending")
      expect(payment.overdue?).to be(true)
    end

    it "retorna false quando status é paid mesmo após due_date" do
      payment = build(:premium_payment, due_date: Date.current - 5.days, status: "paid")
      expect(payment.overdue?).to be(false)
    end

    it "retorna false quando due_date está no futuro" do
      payment = build(:premium_payment, due_date: Date.current + 5.days, status: "pending")
      expect(payment.overdue?).to be(false)
    end

    it "retorna false quando due_date é hoje" do
      payment = build(:premium_payment, due_date: Date.current, status: "pending")
      expect(payment.overdue?).to be(false)
    end
  end
end
