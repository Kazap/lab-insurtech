require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Lab: produção fictícia. Não rodamos em produção real.
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.cache_store = :solid_cache_store rescue :memory_store
  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecation = :log
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.logger($stdout)
  config.i18n.fallbacks = true
end
