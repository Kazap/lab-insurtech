require "rails_helper"

RSpec.describe PolicyCoverage do
  describe "validations" do
    it { is_expected.to validate_presence_of(:coverage_type) }
    it { is_expected.to validate_inclusion_of(:coverage_type).in_array(described_class::COVERAGE_TYPES) }
    it { is_expected.to validate_numericality_of(:max_coverage_cents).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:deductible_cents).is_greater_than_or_equal_to(0) }

    it "rejeita coverage_percentage acima de 100" do
      policy_coverage = build(:policy_coverage, coverage_percentage: 150)
      expect(policy_coverage).not_to be_valid
    end

    it "rejeita coverage_percentage zero" do
      policy_coverage = build(:policy_coverage, coverage_percentage: 0)
      expect(policy_coverage).not_to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:policy) }
    it { is_expected.to have_many(:claims).dependent(:restrict_with_error) }
  end
end
