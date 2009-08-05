Feature: Notifying people of lack of running timers
  In order to reduce time not tracked
  As a god of time
  I want to tell people off
  
  Scenario: Notification
    Given I am logged in to sekret at Harvest
    And time is frozen
    And I am about to get harvest for all entries for day 197 of 2009
    And I am about to get harvest for people
    When I ask Harvest for all people
    And I ask Harvest for all people without running timers
    Then the collection should have 1 users
    
    Given the server is running
    Given the bot's email is "time@mocra.com"
    And the domain is "mocra.com"
    When I run local executable "chronos" with arguments "-d -s localhost"
    Then I have the output
    And the bot should send a stream
    And the bot should receive a stream
    And the bot should see features with multiple mechanisms
    And the bot should auth with DIGEST-MD5
    And the bot should be challenged by the server
    And the bot should send a response to the server
    And the bot should have great success (high five)
    And the bot should send a stream
    And the bot should receive a stream
    Then I have the next line
    Then I have the next line
    Then I have the next line
    And the bot should see features starting a session
    And the bot should send an iq stanza, binding session
    And the bot should receive information pertaining to the session
    And the bot should ask for the roster
    And the bot should announce it is online
    And the bot should receive the names of other people who are online
    And the bot should be notified of 2 presences
    
    # The number below varies depending on how many real world employees are slacking off.
    
    And the bot should have sent 4 messages
    And that should be all, folks
    And the bot dies
    And finally the server should be killed