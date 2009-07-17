Given /^I am about to (\w+) (\w+) for entries for day (\d+) of (\d+)$/ do |method, service, day, year|
  url = "http#{'s' if @ssl}://#{@subdomain + '.' if @subdomain}#{Services[service.downcase.to_sym]}/daily/#{day}/#{year}"
  puts "Registering: #{method.upcase} #{url}"
  # puts fixture_path("#{things}.xml").inspect 
  FakeWeb.register_uri(method.to_sym, url, :file => fixture_path("daily/#{day}-#{year}.xml"))
end

When /^I ask Harvest for all entries on day (\d+) of (\d+)$/ do |day, year|
  @objects = @service.entries.find_all_by_day_and_year(day, year)
  @output = @objects.map(&:attributes).inspect
end
