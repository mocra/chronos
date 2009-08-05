require 'rubygems'
require 'eventmachine'
require 'digest/md5'
require 'base64'
require 'socket'
require 'sequel'
require 'nokogiri'

# Remove messages database
FileUtils.rm("messages") if File.exists?("messages")
# And re-create it
DB = Sequel.sqlite('messages')
DB.create_table :messages do
	primary_key :id
	column :from, :string
	column :to, :string
	column :body, :text
end

class Talka

  # Thanks
  # http://web.archive.org/web/20050224191820/http://cataclysm.cx/wip/digest-md5-crash.html
  # Dunno, may need this later on.
  class Session < Struct.new(:username, :id)
  
  end

  SESSIONS = {}

  module Jabber
  
  
    def receive_data(data)
      determine_ip
      return if data == " "
      xml = Nokogiri::XML(data).root
      method = "parse_#{xml.name}"
    
      if respond_to?(method)
        send(method, xml)
      else
        # Client asks if it can auth, of course you can!
        if iq = /<iq type='set' id='(\d+)'><query xmlns='jabber:iq:auth'><username>(.*?)<\/username><digest>(.*?)<\/digest><\/query><\/iq>/.match(data)
          send_data("<iq type='result' id='#{iq[1]}'><query xmlns='jabber:iq:auth'><username>#{iq[2]}<\/username><digest>#{iq[3]}<\/digest><\/query></iq>")
    
        # Client asks if it can bind resources, of course you can!
        elsif iq = /<iq type='set' id='(\d+)'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'\/><\/iq>/.match(data)
          # Set a unique identifier for this session, merged with their username later on. 
          @session.id = time_hash[0..7].upcase
          send_data("<iq type='result' id='#{iq[1]}'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><jid>#{@session.username}@#{domain_name}/#{@session.id}</jid></bind></iq>")
    
        # Client asks if it can have a session, of course you can!
        elsif iq = /<iq type='set' id='(\d+)'><session xmlns='urn:ietf:params:xml:ns:xmpp-session'\/><\/iq>/.match(data)
          send_data("<iq type='result' id='#{iq[1]}' />")
      
        # Client asks for a roster, we'll just fake one for now.
        # Alice and Bob are subscribed to all users.
        elsif iq = /^<iq type='get'><query xmlns='jabber:iq:roster'\/><\/iq>$/.match(data)
          send_data("<iq type='result' to='#{@session.username}@#{domain_name}/#{@session.id}'><query xmlns='jabber:iq:roster'><item jid='alice@#{domain_name}' subscription='both'/><item jid='bob@#{domain_name}' subscription='both'/></query></iq>")
    
      
        # Client asks if there's anybody out there...
        elsif presence = /^<presence\/>$/.match(data)
          session = SESSIONS[@ip]
          # Since this is not a real server, we'll lie and say there's some people.
          send_data("<presence from='alice@#{domain_name}.111A111' to='#{session.username}@#{domain_name}/#{session.id}'><priority>1</priority></presence>")
          send_data("<presence from='bobby@#{domain_name}.222A222' to='#{session.username}@#{domain_name}/#{session.id}'><priority>1</priority></presence>")
  
      
      
        # Goodbye!
        elsif /<\/stream:stream>/.match(data)
          puts "Goodbye from #{@ip}!"
          SESSIONS.delete(@ip)
      
        # Sometimes sent with auth.
        elsif /<?xml version='1.0' ?>/.match(data)
          # Ignored XML start
    
        # Uh oh.
        else 
          puts "UNKNOWN: #{data}"
        end
      end
    end
  
    def parse_auth(xml)
      case xml['mechanism']
        when "DIGEST-MD5"
          @server_nonce = time_hash
          encodee = "realm=\"localhost\",nonce=\"#{@server_nonce}\",qop=\"auth\",charset=utf-8,algorithm=md5-sess"
          encoded = Base64.encode64(encodee)
          
          send_data("<challenge xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>#{encoded.strip}</challenge>")
        when "PLAIN"
          decoded_string = Base64.decode64(auth[3])
          decoded = Base64.decode64(auth[3]).split("\000")
          # TODO: Check against database
          send_data("<success xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/>")
      end
    end
  
    def parse_stream(xml)
      send_data("<stream:stream xmlns:stream='http://etherx.jabber.org/streams' xmlns='jabber:client' from='#{xml['to']}' xml:lang='en' version='1.0'>")
    
      if session = SESSIONS[@ip]
        initialize_session(session)
      else
        send_data("<stream:features><mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'><mechanism>DIGEST-MD5</mechanism><mechanism>PLAIN</mechanism></mechanisms></stream:features>")
      end
    end
  
    def parse_response(xml)
      return send_data("<success xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/>") if xml.text == ""
      decoded = hashify_response(Base64.decode64(xml.text))
    
      if decoded["nonce"] == @server_nonce
        SESSIONS[@ip] = Session.new(decoded["username"])
        # Server sends specially crafted challenge to client.
        x = "#{decoded["username"]}:#{decoded["realm"]}:#{decoded["response"]}"
        y = Digest::MD5.hexdigest(x)[0..31].to_a.pack 'H*'
        a1 = "#{y}:#{decoded["nonce"]}:#{decoded["cnonce"]}"
        a1 << ":#{decoded["authzid"]}" if decoded["authzid"]
        a2 = "AUTHENTICATE:#{decoded["digest-uri"]}"
        ha1 = Digest::MD5.hexdigest(a1)
        ha2 = Digest::MD5.hexdigest(a2)
        kd = "#{ha1}:#{decoded["nonce"]}:#{decoded["nc"]}:#{decoded["cnonce"]}:#{decoded["qop"]}:#{ha2}"
        z = Base64.encode64(Digest::MD5.hexdigest(kd))
        # Maybe?
    
        send_data("<success xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>#{z.strip}</success>")
      else
        # Stops replay attacks. Bad things. I don't know anything about them.
        # According to this 
        puts "BAD NONCE"
        # Bad nonce
        send_data("<failure xmlns='urn:ietf:params:xml:ns:xmpp-sasl'><temporary-auth-failure/></failure></stream:stream>")
      end
    end
  
    def parse_message(xml)
      DB[:messages] << { :from => @session.username, :to => xml["to"], :body => xml["body"] }
    end
  
    def initialize_session(session)
      send_data("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='#{session.username}_#{time_hash}' from='example.com' version='1.0'><stream:features><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/><session xmlns='urn:ietf:params:xml:ns:xmpp-session'/></stream:features>")
    end
  
  
    def hashify_response(string)
      parts = string.split(",")
      new_parts = {}
      parts.map! { |p| p.split("=") }
      parts.map { |p| new_parts[p.first] = p.last.gsub(34.chr, "") }
      new_parts
    end
  
    def domain_name
      "example.com"
    end
  
    def time_hash
      Digest::MD5.hexdigest(Time.now.to_f.to_s)
    end
  
    def determine_ip
      @port, @ip = Socket.unpack_sockaddr_in(get_peername)
      @session = SESSIONS[@ip]
    end
 
  end
  
  def initialize
    EM.run {
      EM.start_server "0.0.0.0", 5222, Jabber
    }
  end
end

