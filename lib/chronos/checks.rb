module Chronos
  def check_for_timers
    naughty_people = @harvest.people.without_running_timers
    puts "The following people don't have running timers:"
    naughty_people.each do |person|
      puts person.name
      # m = Message.new(person.email, "Please go to http://coopapp.com/groups/#{config["coop"]["group_id"]} and start a timer.").set_type(:chat)
      # @client.send(m)
    end
  end
  
  def check_for_newbies
    @emails = @harvest.people.all.map { |u| u.email }
    @emails.each do |email|
      subscription = Presence.new.set_type(:subscribe)
      subscription.to = email
      @client.send(subscription)
    end
  end
end

    