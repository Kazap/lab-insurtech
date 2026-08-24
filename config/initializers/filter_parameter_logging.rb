# frozen_string_literal: true

# Parâmetros que NUNCA devem aparecer em logs.
# TODO: revisar quando adicionar autenticação real.
Rails.application.config.filter_parameters += %i[
  password
  password_confirmation
  cpf
  credit_card
  token
  secret
]
