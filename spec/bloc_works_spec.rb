require 'bloc_works'
require 'test/unit'
require 'rack/test'

$LOAD_PATH << File.join(File.dirname(__FILE__), "controllers")

class BlocWorksTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    BlocWorks::Application.new
  end

  def test_routing
    get '/test/welcome'
    assert last_response.ok?
    assert_equal("Hello Blocheads!", last_response.body)
  end

  def test_favicon
    get '/favicon.ico'
    assert_equal(404, last_response.status)
  end
end