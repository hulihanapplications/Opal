require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Opal  
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)
    
    config.session_store  :active_record_store , :key => "_opal_session"# alternative: :mem_cache_store 
    #config.secret_token  = "MeFa2RudracRED8trEbuswuZApR7xudAthabeSwAste9Ebremac8EdE5ebaBa7"
    # Use the database for sessions instead of the cookie-based default,
    # which shouldn't be used to store highly confidential information
    # (create the session table with 'rake db:sessions:create')
    #config.action_controller.session_store = :active_record_store

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]    

    # Customize Sanitation
    config.action_view.sanitized_allowed_tags = %w{img a table tr td th br b u i strong p span embed object param ul ol li blockquote pre div sub sup h1 h2 h3 h4 h5 h6 iframe}           
    config.action_view.sanitized_allowed_attributes = %w{href title style width height allowfullscreen frameborder allowscriptaccess src type data name value align}
    
    # Application Name
    def name
      I18n.t("name", :default => String.new)
    end
  end
  
  def self.tmpdir # tmp dir for Opal
    tmpdir = File.writable?(File.join(Dir::tmpdir)) ? File.join(Dir::tmpdir, Rails.application.name) : File.join(Rails.root.to_s, "tmp") # location of the tmp directory for file uploads, etc.
    FileUtils.mkdir_p(tmpdir) if !File.exists?(tmpdir) # create the tmp folder if it doesn't exist
    tmpdir                 
  end
end
