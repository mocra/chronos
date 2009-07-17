require File.join(File.dirname(__FILE__), 'similar')

class Coop
  cattr_accessor :site, :email, :password, :subdomain
  include Similar
  
  class << self 
    def api_domain
      "coopapp.com"
    end
  end
end


require File.join(File.dirname(__FILE__), "coop", "base")
require File.join(File.dirname(__FILE__), "coop", "resource")

# Shortcut for Coop::Base.new
#
# Example:
# Coop(:email      => "jack@exampe.com", 
#         :password   => "secret",
#         :headers    => {"User-Agent => "Harvest Rubygem"})

def Coop(options={})
  Coop::Base.new(options)
end