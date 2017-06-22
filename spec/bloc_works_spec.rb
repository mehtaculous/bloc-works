require 'bloc_works'
require 'test/unit'
require 'rack/test'

class HomepageTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    BlocWorks::Application.new
  end

  def test_status
    get '/'
    assert_equal(200, last_response.status)
  end

  def test_it_says_hello
    get '/'
    assert last_response.ok?
    assert_equal("Hello Blocheads!", last_response.body)
  end
end