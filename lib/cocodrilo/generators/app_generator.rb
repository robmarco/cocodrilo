require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Cocodrilo
  class AppGenerator < Rails::Generators::AppGenerator
    class_option :database, type: :string, aliases: "-d", default: "postgresql",
      desc: "Configure for selected database (options: #{DATABASES.join("/")})"

    class_option :skip_test_unit, type: :boolean, aliases: "-T", default: true,
      desc: "Skip Test::Unit files"

    class_option :skip_turbolinks, type: :boolean, default: true,
      desc: "Skip turbolinks gem"

    class_option :skip_bundle, type: :boolean, aliases: "-B", default: true,
      desc: "Don't run bundle install"

      class_option :skip_test, type: :boolean, aliases: '-T', default: true,
        desc: 'Skip test files'

    def finish_template
      invoke :cocodrilo_customization
      super
    end

    def cocodrilo_customization
      invoke :customize_gemfile
      invoke :setup_application_rb
      invoke :setup_development_environment
      invoke :setup_test_environment
      invoke :setup_production_environment
      invoke :setup_secret_token
      invoke :configure_app
      invoke :setup_figaro
      invoke :setup_capistrano
      invoke :customize_error_pages
      invoke :setup_dotfiles
      invoke :setup_git
      invoke :setup_database
      invoke :setup_background_jobs
      invoke :setup_spring
      invoke :setup_health_task
    end

    def customize_gemfile
      build :set_ruby_to_version_being_used
      bundle_command 'install'
    end

    def setup_application_rb
      say 'Setting up application.rb'
      build :setup_time_zone
      build :setup_locale_configuration
      build :setup_autoload_paths
      # build :setup_lograge
      # build :setup_rack_cors
      # build :setup_generators
    end

    def setup_development_environment
      say 'Setting up the development environment'
      build :add_bullet_gem_configuration
      build :add_paperclip_gem_configuration_to_dev
      build :configure_quiet_assets
    end

    def setup_test_environment
      say 'Setting up the test environment'
      build :setup_test_env_action_dispatch_exceptions
    end

    def setup_production_environment
      say 'Setting up the production environment'
      build :add_paperclip_gem_configuration_to_prod
      build :add_rack_timeout
    end

    def setup_secret_token
      say 'Moving secret token out of version control'
    end

    def setup_figaro
      say 'Setting up figaro gem'
      build :application_yml
    end

    def setup_capistrano
      say 'Setting up capistrano'
      build :copy_capistrano_files
      build :copy_nginx_conf_files
    end

    def configure_app
      say 'Configuring app'
      build :add_puma_configuration
    end

    def customize_error_pages
      say 'Customizing the 500/404/422 pages'
      build :customize_error_pages
    end

    def setup_dotfiles
      build :copy_dotfiles
    end

    def setup_git
      if !options[:skip_git]
        say "Initializing git"
        invoke :init_git
      end
    end

    def init_git
      build :init_git
    end

    def setup_database
      return if options['skip_active_record']
      say 'Setting up database'
      build :use_postgres_config_template if 'postgresql' == options[:database]
      build :create_database
    end

    def setup_background_jobs
      say 'Setting up background jobs'
      build :setup_background_jogs
    end

    def setup_spring
      say "Springifying binstubs"
      build :setup_spring
    end

    def setup_health_task
      say "Setting up health task"
      build :setup_health_task
    end

    protected

    def get_builder_class
      Cocodrilo::AppBuilder
    end

    def using_active_record?
      !options[:skip_active_record]
    end
  end
end
