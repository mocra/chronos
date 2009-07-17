Then /^the (\w+) should have (\d+) (\w+)$/ do |object, count, collection|
  @output.size.should eql(count.to_i)
end

When /^I ask Coop for the first group on a certain date$/ do
  @object = @service.groups.find_by_id_and_date(1, "07-07-2009".to_date)
end
