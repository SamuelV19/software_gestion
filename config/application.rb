require_relative "boot"

require "rails/all"
require 'dotenv'
Dotenv.load

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GestionPapeleria
  class Application < Rails::Application
    config.load_defaults 7.1
    config.autoload_lib(ignore: %w(assets tasks))
    config.i18n.default_locale = :es
    config.time_zone = 'Bogota'
    config.active_record.default_timezone = :local
  end
end
