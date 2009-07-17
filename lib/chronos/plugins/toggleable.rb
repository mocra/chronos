# Adds toggability to a harvest resource.
module Chronos
  module Plugins
    module Toggleable
        
      def toggle
        put(:toggle)
      end
    
    end
  end
end