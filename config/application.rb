require_relative "boot"

require "rails"
# Carregamos apenas o que o projeto realmente usa.
# API-only: sem ActionView, ActionMailer, ActionMailbox, ActionText, ActiveStorage.
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "rails/test_unit/railtie"

# Carrega gems do Gemfile e suas dependências
Bundler.require(*Rails.groups)

module SafeCover
  class Application < Rails::Application
    config.load_defaults 8.1

    # API-only — sem cookies, sem sessions, sem flash, sem CSRF middleware
    config.api_only = true

    # Autoload conforme Rails Zeitwerk (default em Rails 8)
    config.autoload_lib(ignore: %w[assets tasks])

    # Timezone Brasil — operação fictícia em São Paulo
    config.time_zone = "America/Sao_Paulo"
    config.active_record.default_timezone = :local

    # Locale padrão pt-BR (mensagens de erro para usuário final)
    config.i18n.default_locale = :"pt-BR"
    config.i18n.available_locales = [:"pt-BR", :en]
    config.i18n.fallbacks = [:en]
  end
end
