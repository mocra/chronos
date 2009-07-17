require 'rubygems'
require 'fakeweb'
require 'pp'

require File.join(File.dirname(__FILE__), '../test/test_helper')

require 'chronos'

Harvest

FakeWeb.allow_net_connect = false