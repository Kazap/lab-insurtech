# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

# Cobertura opcional: `COVERAGE=1 bundle exec rspec`.
# Precisa ser carregada ANTES do código da aplicação, senão os arquivos já
# lidos pelo autoload não entram no relatório.
if ENV["COVERAGE"]
  require "simplecov"

  SimpleCov.start "rails" do
    enable_coverage :branch
    add_filter "/spec/"
    add_filter "/config/"
    add_group "Concerns", "app/models/concerns"
    add_group "Services", "app/services"
  end
end

require_relative "../config/environment"

# Garante que migrations estão aplicadas antes de rodar specs.
# Rails 8.1 substituiu `migration_context.needs_migration?` por `check_all_pending!`.
begin
  ActiveRecord::Migration.check_all_pending!
rescue ActiveRecord::PendingMigrationError
  ActiveRecord::Tasks::DatabaseTasks.migrate
end

require "rspec/rails"
require "shoulda/matchers"
require "factory_bot_rails"

# Carrega arquivos de support
Rails.root.glob("spec/support/**/*.rb").each { |f| require f }

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join("spec/fixtures").to_s]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
