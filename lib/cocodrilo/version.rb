require 'pathname'

module Cocodrilo
  RAILS_VERSION = "~> 5.0.0"
  RUBY_VERSION = Pathname(__dir__).join('..', '..', '.ruby-version').read.strip
  VERSION = "1.0.0"
end
