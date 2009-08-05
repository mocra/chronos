Given /^I am about to (\w+) (\w+) for all entries for day (\d+) of (\d+)$/ do |method, service, day, year|
  # We have stubbed out only three users, 1 and 2 have 2 and 1 entries respectively, but 3 has 0.
  for i in 1..3
    url = "http#{'s' if @ssl}://test%40test.com:password@#{@subdomain + '.' if @subdomain}#{Services[service.downcase.to_sym]}/daily/#{day}/#{year}?of_user=#{i}"
    FakeWeb.register_uri(method.to_sym, url, :body => fixture_path("daily/#{day}-#{year}-#{i}.xml"))
  end
end

When /^I ask Harvest for all entries on day (\d+) of (\d+)$/ do |day, year|
  @output = @objects = @service.entries.find_all_by_day_and_year(day, year)
end

Then /^there should be (\d+) entries/ do |num|
  @output.size.should eql(num.to_i)
end