# frozen_string_literal: true

source "https://rubygems.org"

ruby "4.0.5"

# Core
gem "rails", "~> 8.1.3"

# Banco local (sem dependência externa)
gem "sqlite3", "~> 2.4"

# Servidor
gem "puma", "~> 6.5"

# JSON e tempo
gem "bootsnap", "~> 1.18", require: false
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "database_cleaner-active_record", "~> 2.2"
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.5"
  gem "mutant", "~> 0.16.3"
  gem "mutant-rspec", "~> 0.16.3"
  gem "rspec-rails", "~> 8.0"
  gem "ruby-lsp", "~> 0.26.9"
  gem "shoulda-matchers", "~> 6.4"
end

group :test do
  # Cobertura de linha — usada na demo de mutation testing para mostrar que
  # 100% de cobertura não significa teste que pega bug.
  gem "simplecov", "~> 0.22", require: false
end

group :development do
  gem "rubocop", "~> 1.78", require: false
  gem "rubocop-rails", "~> 2.32", require: false
  gem "rubocop-rspec", "~> 3.7", require: false
end

# Brasil-specific
gem "cpf_cnpj", "~> 0.5"
