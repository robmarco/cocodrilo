# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'cocodrilo/version'
require 'date'

Gem::Specification.new do |s|
  s.required_ruby_version = ">= #{Cocodrilo::RUBY_VERSION}"
  s.authors = ['Roberto Marco Sánchez (robmarco)']
  s.date = Date.today.strftime('%Y-%m-%d')

  s.description = "Cocodrilo is the base Rails project used at CROCODΞ"
  s.email = 'roberto@crocode.mobi'
  s.executables = ['cocodrilo']
  s.extra_rdoc_files = %w[README.md]
  s.files = `git ls-files`.split("\n")
  s.homepage = 'https://github.com/robmarco/cocodrilo'
  s.name = 'cocodrilo'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.summary = "Generate a minimal Rails app."
  s.version = Cocodrilo::VERSION

  s.add_dependency 'bundler'
  s.add_dependency 'rails', Cocodrilo::RAILS_VERSION

  s.add_development_dependency 'rspec'
end
