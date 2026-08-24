# frozen_string_literal: true

# Bootstrap do mutant: o autoload do Zeitwerk é preguiçoso, então as constantes
# do app só existem depois de referenciadas. Sem o eager_load! o mutant não
# encontra nenhum subject e reporta "Subjects: 0".
require "rails_helper"

Rails.application.eager_load!
