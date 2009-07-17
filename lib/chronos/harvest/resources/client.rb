class Harvest
  module Resources
    class Client < Harvest::Resource
      include Chronos::Plugins::Toggleable
                  
    end
  end
end