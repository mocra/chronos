require File.join(File.expand_path(File.dirname(__FILE__)), 'similar')

class Harvest
  cattr_accessor :site, :subdomain, :email, :password
  include Similar
  
  class << self 
    def api_domain
      "harvestapp.com"
    end
  end
end

require File.join(File.expand_path(File.dirname(__FILE__)), "harvest", "base")
require File.join(File.expand_path(File.dirname(__FILE__)), "harvest", "resource")


# Shortcut for Harvest::Base.new
#
# Example:
# Harvest(:email      => "jack@exampe.com", 
#         :password   => "secret", 
#         :subdomain => "frenchie",
#         :headers    => {"User-Agent => "Harvest Rubygem"})
def Harvest(options={})
  Harvest::Base.new(options)
end