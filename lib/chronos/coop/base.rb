class Coop
  class Base < Harvest::Base
   
    # Requires a subdomain, email, and password.
    # Specifying headers is optional, but useful for setting a user agent.
    def initialize(options={})
      options = options.stringify!
      options.assert_valid_keys("email", "password", "headers", "ssl", "group_id")
      options.assert_required_keys("email", "password")
      @email        = options["email"]
      @password     = options["password"]
      @headers      = options["headers"]
      @ssl          = options["ssl"]
      configure_base_resource
    end
    
    # Below is a series of proxies allowing for easy
    # access to the various resources.
    
    # TODO: Define proxies
    
    def groups
      Coop::Resources::Group
    end

    private
    
      # Configure resource base class so that 
      # inherited classes can access the api.
      def configure_base_resource
        Coop.site = Resource.site = "http#{'s' if @ssl}://#{Coop.api_domain}"
        Coop.email = Resource.user = @email
        Coop.password = Resource.password = @password
        load_resources
      end
      
      # Load the classes representing the various resources.
      def load_resources
        resource_path = File.join(File.dirname(__FILE__), "resources")
        Similar.load_all_ruby_files_from_path(resource_path)
      end
                
  end
end
