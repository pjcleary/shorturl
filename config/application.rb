require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
module Shorturl
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # autoload lib to get the utility functions
    config.autoload_paths += %W(#{config.root}/lib/assets)
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    #
    #
    # use rack attach for rate limiting
    # this can also be used to blacklist IPs, if necessary
    config.middleware.use Rack::Attack
  end
end
