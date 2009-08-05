require 'xmpp4r'
require 'xmpp4r/roster/helper/roster'
require 'yaml'
module Chronos
  class Bot
    # From XMPP4R
    include Jabber
    Dir[File.join(File.dirname(__FILE__), "bot", "*.rb")].each { |f| require f }

    def initialize(options={})
      # TODO: Replace with YAML
      @config = {}
      @config["coop"] = { "email" => "radar@mocra.com", "password" => "temporarypassword12345", "group_id" => "3965" }
      @config["harvest"] = { "email" => "radar@mocra.com", "password" => "temporarypassword12345", "subdomain" => "mocra"}
      @config["jabber"] = { "email" => "time@localhost", "password" => "123456"}
      
      @coop    = Coop(@config["coop"])
      @harvest = Harvest(@config["harvest"])


      Jabber.debug = options[:debug]

      # Start the connection
      @jid = JID.new(@config["jabber"]["email"])
      @client = Client.new(@jid)
      @client.connect(options[:server] || @config["jabber"]["server"] || "talk.google.com")
      @client.auth(@config["jabber"]["password"])
      
      # Helpers
      @roster = Roster::Helper.new(@client)
      
      # Callbacks
      @client.add_message_callback { |m| parse(m) }
      @roster.add_presence_callback { |item, oldpres, pres| presence(item, oldpres, pres) }
      
      if options[:check]
        check_for_newbies
        check_for_timers
      else
        while true do
          check_for_newbies
          check_for_timers
          sleep(120)
        end
      end
    end 
  end
end