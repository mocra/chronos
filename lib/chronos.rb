$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'chronos/similar'
require 'activeresource'
require 'nokogiri'
Similar.load_all_ruby_files_from_path(File.join(File.dirname(__FILE__), "chronos", "plugins"))

require 'chronos/harvest'
require 'chronos/coop'

$:.unshift(File.join(File.dirname(__FILE__), "chronos"))
module Chronos
  VERSION = '0.0.1'
end