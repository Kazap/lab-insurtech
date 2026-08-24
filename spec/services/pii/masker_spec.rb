# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pii::Masker do
  describe ".mask_cpf" do
    it "mascara CPF com formato padrão" do
      expect(described_class.mask_cpf("123.456.789-01")).to eq("***.***.***-01")
    end

    it "mascara CPF sem pontuação" do
      expect(described_class.mask_cpf("12345678901")).to eq("***.***.***-01")
    end

    it "retorna nil para entrada vazia" do
      expect(described_class.mask_cpf(nil)).to be_nil
      expect(described_class.mask_cpf("")).to be_nil
    end

    it "retorna entrada original quando não é um CPF válido" do
      expect(described_class.mask_cpf("abc")).to eq("abc")
    end
  end

  describe ".mask_email" do
    it "mantém primeiro caractere e mascara o resto do local" do
      expect(described_class.mask_email("joao@gmail.com")).to eq("j***@gmail.com")
    end

    it "preserva o domínio" do
      expect(described_class.mask_email("anderson@kazap.com.br")).to eq("a***@kazap.com.br")
    end

    it "retorna nil para entrada vazia" do
      expect(described_class.mask_email(nil)).to be_nil
      expect(described_class.mask_email("")).to be_nil
    end

    it "retorna entrada original quando não há @" do
      expect(described_class.mask_email("sem-arroba")).to eq("sem-arroba")
    end
  end

  describe ".mask_phone" do
    it "mantém DDD e últimos 4 dígitos" do
      expect(described_class.mask_phone("11987654321")).to eq("(11) ****-4321")
    end

    it "lida com formato brasileiro com pontuação" do
      expect(described_class.mask_phone("(11) 98765-4321")).to eq("(11) ****-4321")
    end

    it "retorna nil para entrada vazia" do
      expect(described_class.mask_phone(nil)).to be_nil
    end

    it "retorna entrada original quando muito curta" do
      expect(described_class.mask_phone("123")).to eq("123")
    end
  end
end
