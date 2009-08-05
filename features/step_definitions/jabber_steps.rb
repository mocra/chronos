Given /^the server is running$/ do
  if File.exist?("server.pid")
    old_pid = File.read("server.pid").to_i
    Process.kill("HUP", old_pid) rescue nil
  end
  f = File.open("server.pid", "w+")
  @pid = Kernel.fork { Talka.new }
  f.write(@pid)
  f.close
end

Given /^the bot's email is (.*?)$/ do |email|
  @email = email
end

Given /^the domain is "(.*?)"$/ do |domain|
  @domain = domain
end

Then /^I have the output$/ do
  @sample = File.readlines(@stdout).delete_if { |l| l.scan(/^\s{4}</).empty? }
end


Then /^I have the next line$/ do
  # XML lines always begin with opening of tag.
  @xml = Nokogiri::XML(@sample.shift).root
end

# Generally listed in the order they are received.
# Partially stolen from: http://xmpp.org/rfcs/rfc3920.html

Then /^the bot should send a stream$/ do
  Then "I have the next line"
  @xml.name.should eql("stream")
  @xml['to'].should eql("localhost")
end

Then /^the bot should receive a stream$/ do
  Then "I have the next line"
  @xml.name.should eql("stream")
  @xml['from'].should eql("localhost")
end

Then /^the bot should see features with multiple mechanisms$/ do
  Then "I have the next line"
  @xml.name.should eql("features")
  mechanisms = @xml.children.first
  mechanisms.name.should eql("mechanisms")
  mechanisms.children.to_a.size.should eql(2)
  
  first_mech  = mechanisms.children[0]
  second_mech = mechanisms.children[1]
  
  first_mech.name.should eql("mechanism")
  first_mech.text.should eql("DIGEST-MD5")
  
  second_mech.name.should eql("mechanism")
  second_mech.text.should eql("PLAIN")
end


Then /^the bot should auth with (.*?)$/ do |auth|
  # One for received
  Then "I have the next line"
  # One for processing
  Then "I have the next line"
  @xml['mechanism'].should eql("DIGEST-MD5")
end


Then /^the bot should be challenged by the server$/ do
  Then "I have the next line"
  @xml.name.should eql("challenge")
  
  # Usually the nonce would change, but because we have frozen time it will not.
  Base64.decode64(@xml.text).should eql("realm=\"localhost\",nonce=\"99d4d60b78f9a8737070")
end


Then /^the bot should send a response to the server$/ do
  Then "I have the next line"
  @xml.name.should eql("response")
  @xml.text.length.should eql(296)
  @xml.text.scan(/^cmVzcG9uc2U9/).should_not be_empty
  @xml.text.scan(/sbmM9MDAwMDAwMDE=$/).should_not be_empty
  # Example: cmVzcG9uc2U9NWVmMzRjNGJhZGFkNmI0YWI3NmUzYTRiMzRiNGQ4YzEsY25vbmNlPSJkMmE5YWIyNjdmMGI5YWMyODU5Zjk1MDgxNzYxNTk4MCIsZGlnZXN0LXVyaT0ieG1wcC9sb2NhbGhvc3QiLHVzZXJuYW1lPSJ0aW1lIixjaGFyc2V0PXV0Zi04LHFvcD1hdXRoLHJlYWxtPSJsb2NhbGhvc3QiLG5vbmNlPSI5OWQ0ZDYwYjc4ZjlhODczNzA3MDZmODRlMDg0MTgzNSIsbmM9MDAwMDAwMDE=
    # For those of you who do not speak Base64 (and why not?!), the previous consists of the following:
    #
    # response=5ef34c4badad6b4ab76e3a4b34b4d8c1,
    # cnonce=\"d2a9ab267f0b9ac2859f950817615980\",
    # digest-uri=\"xmpp/localhost\",
    # username=\"time\",
    # charset=utf-8,
    # qop=auth,
    # realm=\"localhost\",
    # nonce=\"99d4d60b78f9a87370706f84e0841835\",
    # nc=00000001
    #
    # Line breaks added for readibility.
  
end

Then /^the bot should have great success \(high five\)$/ do
  Then "I have the next line"
  @xml.name.should eql("success")
end

Then /^the bot should see features starting a session$/ do
  @xml.name.should eql("features")
  @xml.children[0].name.should eql("bind")
  @xml.children[1].name.should eql("session")
end


Then /^the bot should send an iq stanza, binding session$/ do
  Then "I have the next line"
  @xml.name.should eql("iq")
  @xml.children[0].name.should eql("bind")
  # Bot finally gets around to parsing features line.
  Then "I have the next line"
end

Then /^the bot should receive information pertaining to the session$/ do
  Then "I have the next line"
  @xml.name.should eql("iq")
  @xml["type"].should eql("result")
  @xml["id"].should_not be_blank
  @xml.children[0].name.should eql("bind")
  Then "I have the next line"
  @xml.name.should eql("iq")
  @xml["type"].should eql("set")
  @xml["id"].should_not be_blank
  @xml.children[0].name.should eql("session")
  Then "I have the next line"
  @xml.name.should eql("iq")
  @xml["type"].should eql("result")
  @xml["id"].should_not be_blank
end

Then /^the bot should ask for the roster$/ do
  Then "I have the next line"
  @xml.name.should eql("iq")
  @xml.children[0].name.should eql("query")
end

Then /^the bot should announce it is online$/ do
  Then "I have the next line"
  @xml.name.should eql("presence")
end

Then /^the bot should receive the names of other people who are online$/ do
  Then "I have the next line"
  @xml.name.should eql("iq")
  @xml['type'].should eql("result")
  @xml['to'].scan(/^time@example.com/).should_not be_empty
  # Yes, it may NOT be query, but for the sake of the argument we shall call it that.
  # No, "@maybe_query" is not an appropriate name.
  @query = @xml.children[0]
  @query.name.should eql("query")
  
  first_item = @query.children[0]
  first_item.name.should eql("item")
  first_item['jid'].should eql('alice@example.com')
  first_item['subscription'].should eql('both')
  
  second_item = @query.children[1]
  second_item.name.should eql("item")
  second_item['jid'].should eql("bob@example.com")
  second_item['subscription'].should eql('both')
  
  @query.children[1].name.should eql("item")
  
end

Then /^the bot should be notified of a presence$/ do
  Then "I have the next line"
  @xml.name.should eql("presence")
  @xml['from'].should_not be_nil
end

Then /^the bot should be notified of (\d+) presences$/ do |num|
  Then "I have the next line"
  num.to_i.times do 
    Then "the bot should be notified of a presence"
  end
end

Then /^the bot should have sent (\d+) messages$/ do |num|
  # Remove parsing messages from presences
  Then "I have the next line"
  Then "I have the next line"
  num.to_i.times do
    Then "I have the next line"
    @xml.name.should eql("message")
  end
end

Then /^the bot should show me the next thing$/ do
  puts @sample.inspect 
  Then "I have the next line"
  puts @xml.inspect
end

Then /^that should be all, folks$/ do
  @sample.should be_empty
end

Then /^finally the server should be killed$/ do
  Process.kill("TERM", @pid)
end