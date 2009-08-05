Feature: People
  In order to perform crud operations on projects
  As an API user
  I want it to be easy!
  
  Scenario: /people
  Given I am logged in to sekret at Harvest
  And I am about to get harvest for people
  When I ask Harvest for all people
  Then the name of the first element should be Person People