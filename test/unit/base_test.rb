require File.join(File.dirname(__FILE__), "..", "test_helper")

class BaseTest < Test::Unit::TestCase
    
  context "A Harvest object" do 
    setup do 
      @password   = "secret"
      @email      = "james@example.com"
      @subdomain = "bond"
      @headers    = {"User-Agent" => "HarvestGemTest"}
      @harvest    = Harvest::Base.new(:email      => @email, 
                                      :password   => @password, 
                                      :subdomain => @subdomain,
                                      :headers    => @headers)
    end
    
    should "initialize the resource base class" do
      assert_equal "http://bond.harvestapp.com", Harvest::Resource.site.to_s
      assert_equal @password, Harvest::Resource.password
      assert_equal @email,    Harvest::Resource.user
    end
        
    should "raise an error if subdomain is missing" do
      assert_raise_plus ArgumentError, "Missing required option(s): subdomain" do
        Harvest(:email => "joe@example.com", :password => "secret")
      end
    end
    
    should "raise an error if password is missing" do
      assert_raise_plus ArgumentError, "Missing required option(s): password" do
        Harvest(:email => "joe@example.com", :subdomain => "time")
      end
    end
    
    should "raise an error if email is missing" do
      assert_raise_plus ArgumentError, "Missing required option(s): email" do
        Harvest(:password => "secret", :subdomain => "time")
      end
    end
    
    should "set the headers" do
      assert_equal @headers, Harvest::Resource.headers
    end
    
    should "return the Client class" do
      assert_equal Harvest::Resources::Client, @harvest.clients
    end
    
    should "return the Expense class" do
      assert_equal Harvest::Resources::Expense, @harvest.expenses
    end
    
    should "return the ExpenseCategory class" do
      assert_equal Harvest::Resources::ExpenseCategory, @harvest.expense_categories
    end
    
    should "return the Person class" do
      assert_equal Harvest::Resources::Project, @harvest.projects
    end
    
    should "return the Project class" do
      assert_equal Harvest::Resources::Project, @harvest.projects
    end
    
    should "return the Task class" do
      assert_equal Harvest::Resources::Task, @harvest.tasks
    end
    
    context "with SSL enabled" do
      setup do
        @harvest = Harvest::Base.new(:email      => @email,
                                     :password   => @password,
                                     :subdomain => @subdomain,
                                     :headers    => @headers,
                                     :ssl        => true)
      end

      should "have https in URL" do
        assert_equal "https://bond.harvestapp.com", Harvest::Resource.site.to_s
      end
    end
  end
  
end