
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "active_record/archiver"

require "minitest/autorun"

require 'support/rails_convenience_methods'
require 'support/rails_activerecord_simulation'

require 'mocha/minitest'
require 'webmock/minitest'

require 'pry'
require 'byebug'

require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(:color => false)]


def abort(string)
  raise SystemExit.new(string)
end


def assert_abort
  seen_exception = false

  yield

rescue SystemExit
  seen_exception = true

ensure
  assert seen_exception
end

class Minitest::Test

  def setup

    #Rails.cache.clear
    super
  end

end