require 'xmpp4r'
module Chronos
  class Bot
    include Jabber
    def check_for_timers
      naughty_people = @harvest.people.without_running_timers
      naughty_people.each do |person|
        puts "messaging #{person.email}"
        # next if !@online.include?(person.email) # Person is not online, do not send them a message
        m = Message.new(person.email, "Hey #{person.name}, Please go to http://coopapp.com/groups/#{@config["coop"]["group_id"]} and start a timer.").set_type(:chat).set_id('1')
        @client.send(m)
      end
    end
  
    def check_for_newbies
      # Reset the people who are online...
      @online = []
      # Hey server, who's online now?
      # Also announces client's arrival.
      # Refills @online via presence method.
      @client.send(Presence.new)
      
      check_for_subscriptions
      
      # Ask to be the friend of those who have 
      @unsubscribed.each do |email|
        subscription = Presence.new.set_type(:subscribe)
        subscription.to = email
        @client.send(subscription)
      end
    end
    
    # Work out who's accepted our invites.
    # No point trying to send messages to people who have not.
    def check_for_subscriptions
      mainthread = Thread.current
      # Await roster.
      @roster.add_query_callback { |iq| mainthread.wakeup }

      Thread.stop

      @unsubscribed = []
      @roster.groups.each do |group|
        @roster.find_by_group(group).each do |item|
          @unsubscribed << item.jid if item.subscription == "none"
        end
      end
    end
    
    # Called when a user changes their presence.
    def presence(item, oldpres, pres)
      @online << item.jid
    end
  end
end

    