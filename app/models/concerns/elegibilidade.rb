# frozen_string_literal: true

# Regras de elegibilidade usadas na contratação de apólices.
#
# ALVO DA DEMO DE MUTATION TESTING: o spec correspondente passa e reporta
# cobertura alta, mas não fixa os limites das comparações (18 e 50_000).
module Elegibilidade
  IDADE_MINIMA = 18
  VALOR_MAXIMO_SEM_ANALISE = 50_000

  def elegivel?(idade)
    idade >= IDADE_MINIMA
  end

  def exige_analise?(valor_segurado)
    valor_segurado > VALOR_MAXIMO_SEM_ANALISE
  end
end
