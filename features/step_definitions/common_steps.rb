Given /^I am about to (\w+) (\w+) for (\w+[\/?\w+?]{1,})$/ do |method, service, things|
  url = "http#{'s' if @ssl}://#{@subdomain + '.' if @subdomain}#{Services[service.downcase.to_sym]}/#{things}"
  # puts "Registering: #{method.upcase} #{url}"
  # puts fixture_path("#{things}.xml").inspect 
  FakeWeb.register_uri(method.to_sym, url, :file => fixture_path("#{things}.xml"))
end

Given /^I am logged in to (.*?) at (.*?)$/ do |subdomain, service|
  standard = { :email => "test@test.com", :password => "password" }
  @service = if service == "Harvest"
    
    # For later on, when we fake the web
    @subdomain = subdomain
    
    send(service, standard.merge(:subdomain => @subdomain))
  else
    send(service, standard)
  end
end

Given /^time is frozen$/ do
  time = "16-07-2009".to_time
  Time.stubs(:now).returns(time)
end

When /^I ask (\w+) for all (\w+)$/ do |service, things|
  @objects = @service.send(things).find(:all)
  @output = @objects.map(&:attributes).inspect
end

When /^I ask (\w+) for the first (\w+)$/ do |service, thing|
  @object = @service.send(thing.pluralize).find(1)
  @output = @object.attributes
end

Then /^the (\w+) should be (.*?)$/ do |field, value|
  @object.send(field).should eql(value)
end

Then /^the (\w+) of the first element should be (.*?)$/ do |field, value|
  @objects.first.send(field).should eql(value)
end

Then /^I should be given a (.*?) (.*?)$/ do |service, resource|
  @object.is_a?(eval("#{service}::Resources::#{resource}")).should be_true
end


