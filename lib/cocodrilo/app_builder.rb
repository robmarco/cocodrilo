require "forwardable"

module Cocodrilo
  class AppBuilder < Rails::AppBuilder
    include Cocodrilo::Actions
    extend Forwardable

    # Configuration files =================================

    def readme
      template 'README.md.erb', 'README.md'
    end

    def gitignore
      copy_file "cocodrilo_gitignore", ".gitignore"
    end

    def gemfile
      template "Gemfile.erb", "Gemfile"
    end

    def setup_secret_token
      template 'secrets.yml', 'config/secrets.yml', force: true
    end

    def application_yml
      copy_file "application.yml", "config/application.yml"
    end

    def copy_nginx_conf_files
      copy_file "nginx.conf.erb", "config/nginx.conf"
    end

    def copy_capistrano_files
      empty_directory 'config/deploy'
      copy_file "capistrano_production.rb", "config/deploy/production.rb"
      copy_file "capistrano_staging.rb", "config/deploy/staging.rb"
      copy_file "capistrano_deploy.rb.erb", "config/deploy.rb"
    end

    def add_puma_configuration
      copy_file "puma.rb", "config/puma.rb", force: true
    end

    def copy_dotfiles
      copy_file "dotfiles/rspec", ".rspec"
      copy_file "dotfiles/rubocop.yml", ".rubocop.yml"
    end

    def use_postgres_config_template
      template 'postgresql_database.yml.erb', 'config/database.yml',
        force: true
    end

    def setup_background_jobs
      copy_file 'active_job.rb', 'config/initializers/active_job.rb'
      copy_file 'sidekiq.yml', 'config/sidekiq.yml'
    end

    def set_ruby_to_version_being_used
      create_file '.ruby-version', "#{Cocodrilo::RUBY_VERSION}\n"
    end

    def configure_time_formats
      template "config_locales_en.yml.erb", "config/locales/en.yml"
    end

    def setup_health_task
      copy_file "health.rake", "lib/tasks/health.rake"
      append_file "Rakefile", %{\ntask default: "health"\n}
    end

    # Files injections ====================================

    def setup_time_zone
      config = <<RUBY
  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
  config.time_zone = 'Madrid'
RUBY
      configure_application_file(config)
    end

    def setup_locale_configuration
      config = <<RUBY
  # Locale
  # config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  # config.i18n.enforce_available_locales = false
  # config.i18n.default_locale = :es
RUBY
      configure_application_file(config)
    end

    def setup_autoload_paths
      config = <<RUBY
  # Add to autoload_paths
  config.autoload_paths += %W{lib}
RUBY
      configure_application_file(config)
    end

    def setup_lograge
      config = <<RUBY
  # Logs
  unless Rails.env.test?
    log_level = String(ENV['LOG_LEVEL']||"info").upcase
    config.log_level = log_level
    config.lograge.enabled = true

    INTERNAL_PARAMS = %w(controller action format _method only_path)

    config.lograge.custom_options = lambda do |event|
      payload = event.payload
      params  = payload[:params].except(*INTERNAL_PARAMS)
      host    = payload[:host]
      ip      = payload[:ip]
      { params: params, host: host, ip: ip, time: event.time }
    end
  end
RUBY
      configure_application_file(config)
    end

    def setup_rack_cors
      config = <<RUBY
  # Rack::Cors configuration
  config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :post, :options]
    end
  end
RUBY

      configure_application_file(config)
    end

    def setup_generators
      config = <<RUBY
  # Generators
  config.generators do |g|
    g.helper false
    g.javascript_engine false
    g.stylesheets false
    g.request_specs false
    g.routing_specs false
    g.view_specs false
    g.test_framework nil
    # g.test_framework :rspec
    #                  :fixtures => false,
    #                  :model_specs => true,
    #                  :view_specs => false,
    #                  :helper_specs => false,
    #                  :routing_specs => false,
    #                  :controller_specs => true,
    #                  :request_specs => false
  end
RUBY

      configure_application_file(config)
    end

    def add_bullet_gem_configuration
      config = <<RUBY
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.rails_logger = true
  end
RUBY

      inject_into_file(
        "config/environments/development.rb",
        config,
        after: "config.file_watcher = ActiveSupport::EventedFileUpdateChecker\n",
      )
    end

    def add_paperclip_gem_configuration_to_dev
      config = <<RUBY
  config.paperclip_defaults = {
    :storage => :s3,
    :s3_region => ENV['AWS_REGION'],
    :s3_credentials => {
      :bucket => ENV['S3_BUCKET_NAME'],
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }
  end
RUBY

      inject_into_file(
        "config/environments/development.rb",
        config,
        after: "config.file_watcher = ActiveSupport::EventedFileUpdateChecker\n",
      )
    end

    def add_paperclip_gem_configuration_to_prod
      config = <<RUBY
  config.paperclip_defaults = {
    :storage => :s3,
    :s3_region => ENV['AWS_REGION'],
    :s3_credentials => {
      :bucket => ENV['S3_BUCKET_NAME'],
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }
  end
RUBY

      inject_into_file(
        "config/environments/production.rb",
        config,
        after: "config.active_record.dump_schema_after_migration = false\n",
      )
    end

    def add_rack_timeout
      config = "Rack::Timeout.timeout = (ENV['RACK_TIMEOUT'] || 10).to_i"
      inject_into_file(
        "config/environments/production.rb",
        config,
        after: "config.active_record.dump_schema_after_migration = false\n",
      )
    end

    def customize_error_pages
      meta_tags =<<-EOS
  <meta charset="utf-8" />
  <meta name="ROBOTS" content="NOODP" />
  <meta name="viewport" content="initial-scale=1" />
      EOS

      %w(500 404 422).each do |page|
        inject_into_file "public/#{page}.html", meta_tags, after: "<head>\n"
        replace_in_file "public/#{page}.html", /<!--.+-->\n/, ''
      end
    end

    def setup_test_env_action_dispatch_exceptions
      gsub_file(
        'config/environments/test.rb',
        'config.action_dispatch.show_exceptions = false',
        'config.action_dispatch.show_exceptions = true'
      )
    end

    def configure_quiet_assets
      config = <<-RUBY
    config.assets.quiet = true
      RUBY

      inject_into_class "config/application.rb", "Application", config
    end

    # Execute commands ====================================

    def create_database
      bundle_command 'exec rake db:create db:migrate'
    end

    def setup_spring
      bundle_command "exec spring binstub --all"
    end

    # Git =================================================

    def init_git
      run 'git init'
    end

  end
end
