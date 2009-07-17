class Harvest
  module Resources
    class Task < Harvest::Resource
      include Chronos::Plugins::Toggleable
    end
  end
end