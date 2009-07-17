require "rubygems"
require "active_resource"
require "active_resource_throttle"
require "test/unit"
require "shoulda"
require "mocha"
require 'fakeweb'

$:.unshift(File.dirname(__FILE__), "..", "lib")


FakeWeb.allow_net_connect = false

# The integration test will not run by default.
# To run it, type:
#   rake test:integration
#
# If running the integration test, login credentials
# must be specified here. The integration test verifies
# that various resources in a Harvest account can be created, 
# deleted, updated, destroyed, etc.
#
# It's best to run this test on a trial account, where no 
# sensitive data can be manipulated.
#
# Leave these values nil if not running the integration test.
$integration_credentials = {:email      => nil,
                            :password   => nil,
                            :subdomain => nil}

def fixture_path(file)
  File.join("test/xml", file)
end

def fake_harvest_url(path, method=:get)
  FakeWeb.register_uri(method, "http://test.harvestapp.com/#{path}.xml", :file => fixture_path("#{path}.xml"))
end

def fake_coop_url(path, method=:get)
  FakeWeb.register_uri(method, "http://coopapp.com/#{path}.xml", :file => fixture_path("#{path}.xml"))
end

# Custom assert_raise to test exception message in addition to the exception itself.
class Test::Unit::TestCase
  def assert_raise_plus(exception_class, exception_message, message=nil, &block)
    begin
      yield
    rescue => e
      error_message = build_message(message, '<?>, <?> expected but was <?>, <?>', exception_class, exception_message, e.class, e.message)
      assert_block(error_message) { e.class == exception_class && e.message == exception_message }
    else
      error_message = build_message(nil, '<?>, <?> expected but raised nothing.', exception_class, exception_message)
      assert_block(error_message) { false }
    end
  end
end