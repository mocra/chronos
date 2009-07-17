Feature: Entries
  In order to perform crud operations on entries
  As an API user
  I want it to be easy!
  
  Scenario: /entries/197/2009
  Given I am logged in to sekret at Harvest
  And I am about to get harvest for entries for day 197 of 2009
  When I ask Harvest for all entries on day 197 of 2009
  Then the project of the first element should be A Project
  Then the client of the first element should be A Client