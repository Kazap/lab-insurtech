# frozen_string_literal: true

require "rails_helper"

RSpec.describe Result do
  describe ".success" do
    it "cria resultado bem-sucedido com data" do
      result = described_class.success(data: { id: 1 })
      expect(result).to be_success
      expect(result).not_to be_failure
      expect(result.data).to eq(id: 1)
      expect(result.message).to be_nil
    end

    it "permite data nula" do
      result = described_class.success
      expect(result).to be_success
      expect(result.data).to be_nil
    end
  end

  describe ".failure" do
    it "cria resultado de falha com mensagem" do
      result = described_class.failure(message: "Algo deu errado")
      expect(result).to be_failure
      expect(result).not_to be_success
      expect(result.message).to eq("Algo deu errado")
    end

    it "aceita código opcional" do
      result = described_class.failure(message: "Não autorizado", code: "unauthorized")
      expect(result.code).to eq("unauthorized")
    end
  end
end
