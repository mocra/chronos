require 'xmpp4r'
require 'yaml'
module Chronos
  class Runner
      # From XMPP4R
      include Jabber
      Dir[File.join(File.dirname(__FILE__), "chronos", "/**/*.rb")].each { |f| require f }


      def initialize(debug = false)
        @coop    = Coop(config["coop"])
        @harvest = Harvest(config["harvest"])


        Jabber.debug = debug

        # Start the connection
        @jid = JID.new(config["jabber"]["email"])
        @client = Client.new(@jid)
        @client.connect(config["jabber"]["server"] || "talk.google.com")
        @client.auth(config["jabber"]["password"])

        @client.add_message_callback { |m| parse(m) }

        puts "Logging in!"
        @client.send(Presence.new)

        while true do
          check_for_timers
          check_for_newbies
          sleep(120)
        end
      end

    end 
  end
end