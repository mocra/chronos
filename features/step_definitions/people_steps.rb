When /^I ask Harvest for all people without running timers$/ do
  @output = @service.people.without_running_timers
end
