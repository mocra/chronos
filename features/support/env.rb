gem 'aslakhellesoy-cucumber'
require 'cucumber'
gem 'rspec'
require 'spec'


require File.join(File.dirname(__FILE__), '../../test/test_helper')

require 'chronos'


Before do
  @tmp_root = File.dirname(__FILE__) + "/../../tmp"
  @home_path = File.expand_path(File.join(@tmp_root, "home"))
  FileUtils.rm_rf   @tmp_root
  FileUtils.mkdir_p @home_path
  ENV['HOME'] = @home_path
end

gem "fakeweb"
require "fakeweb"

Before do
  FakeWeb.allow_net_connect = false
end

# Fake Jabber Server
# 100% fake, 10(0)% reliable.
require 'talka'