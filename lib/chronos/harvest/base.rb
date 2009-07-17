class Harvest
  class Base
   
    # Requires a subdomain, email, and password.
    # Specifying headers is optional, but useful for setting a user agent.
    def initialize(options={})
      options = options.stringify!
      options.assert_valid_keys("email", "password", "subdomain", "headers", "ssl")
      options.assert_required_keys("email", "password", "subdomain")
      @email        = options["email"]
      @password     = options["password"]
      @subdomain   = options["subdomain"]
      @headers      = options["headers"]
      @ssl          = options["ssl"]
      configure_base_resource
    end
    
    # Below is a series of proxies allowing for easy
    # access to the various resources.
    
    # Clients.
    def clients
      Harvest::Resources::Client
    end
    
    # Entries.
    def entries
      Harvest::Resources::Entry
    end
    
    # Expenses.
    def expenses
      Harvest::Resources::Expense
    end
    
    # Expense categories.
    def expense_categories
      Harvest::Resources::ExpenseCategory
    end
    
    # People.
    # Also provides access to time entries.
    def people
      Harvest::Resources::Person
    end
    
    # Projects.
    # Provides access to the assigned users and tasks
    # along with reports for entries on the project.
    def projects
      Harvest::Resources::Project
    end
    
    # Tasks.
    def tasks
      Harvest::Resources::Task
    end

    # Invoices
    def invoices
      Harvest::Resources::Invoice
    end

    private
    
      # Configure resource base class so that 
      # inherited classes can access the api.
      def configure_base_resource
        Harvest.site = Resource.site = "http#{'s' if @ssl}://#{@subdomain}.#{Harvest.api_domain}"
        Harvest.subdomain = @subdomain
        Harvest.email = Resource.user = @email
        Harvest.password = Resource.password = @password
        load_resources
      end
      
      # Load the classes representing the various resources.
      def load_resources
        resource_path = File.join(File.dirname(__FILE__), "resources")
        Similar.load_all_ruby_files_from_path(resource_path)
      end
                
  end
end
