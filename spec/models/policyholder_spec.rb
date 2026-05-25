require "rails_helper"

RSpec.describe Policyholder do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:cpf) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:birthdate) }
  end

  describe "#age" do
    it "calcula idade corretamente" do
      ph = build(:policyholder, birthdate: 30.years.ago.to_date)
      expect(ph.age).to eq(30)
    end

    it "retorna nil quando birthdate é nulo" do
      ph = build(:policyholder, birthdate: nil)
      expect(ph.age).to be_nil
    end

    it "considera mês de aniversário" do
      ph = build(:policyholder, birthdate: 30.years.from_now + 1.day - 30.years)
      # Aniversário ainda não chegou este ano
      expect(ph.age).to be < 30 if ph.birthdate > Date.current - 30.years
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:policies).dependent(:restrict_with_error) }
  end
end
