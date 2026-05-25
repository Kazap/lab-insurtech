ENV["RAILS_ENV"] ||= "test"
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
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

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
