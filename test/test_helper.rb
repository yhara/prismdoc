require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'rails/test_help'

  class ActiveSupport::TestCase
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    fixtures :all
  end
end

Spork.each_run do
end

# --- Spork Instructions ---
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
