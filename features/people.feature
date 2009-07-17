Feature: People
  In order to perform crud operations on projects
  As an API user
  I want it to be easy!
  
  Scenario: /people
  Given I am logged in to sekret at Harvest
  And I am about to get harvest for people
  When I ask Harvest for all people
  Then the name of the first element should be Person People
     
  Scenario: Messaging people without running timers
  Given I am logged in to sekret at Harvest
  And time is frozen
  And I am about to get harvest for entries for day 197 of 2009
  And I am about to get harvest for people
  When I ask Harvest for all people
  And I ask Harvest for all people without running timers
  Then the collection should have 1 users