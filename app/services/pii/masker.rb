# frozen_string_literal: true

module Pii
  # Mascara dados pessoais antes de retornar em respostas API ou logs.
  #
  # Padrão definido em CLAUDE.md:
  # - CPF:   ***.***.***-89
  # - Email: j***@gmail.com
  # - Phone: (11) ****-1234
  #
  class Masker
    def self.mask_cpf(cpf)
      return nil if cpf.blank?

      digits = cpf.to_s.gsub(/\D/, "")
      return cpf if digits.length != 11

      "***.***.***-#{digits[-2..]}"
    end

    def self.mask_email(email)
      return nil if email.blank?
      return email unless email.include?("@")

      local, domain = email.split("@", 2)
      first_char = local[0] || ""
      "#{first_char}***@#{domain}"
    end

    def self.mask_phone(phone)
      return nil if phone.blank?

      digits = phone.to_s.gsub(/\D/, "")
      return phone if digits.length < 10

      ddd = digits[0..1]
      last_four = digits[-4..]
      "(#{ddd}) ****-#{last_four}"
    end
  end
end
