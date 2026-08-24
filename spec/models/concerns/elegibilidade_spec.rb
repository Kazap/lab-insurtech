# frozen_string_literal: true

require "rails_helper"

RSpec.describe Elegibilidade do
  subject(:regra) { Class.new { include Elegibilidade }.new }

  it "aceita maior de idade" do
    expect(regra.elegivel?(25)).to be true
  end

  it "recusa menor de idade" do
    expect(regra.elegivel?(15)).to be false
  end

  it "exige análise para valor alto" do
    expect(regra.exige_analise?(80_000)).to be true
  end
end
