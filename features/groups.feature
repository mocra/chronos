Feature: Groups
  In order to perform crud operations on projects
  As an API user
  I want it to be easy!
     
  Scenario: /groups
  Given I am logged in to sekret at Coop
  Given I am about to get Coop for groups
  When I ask Coop for all groups
  Then the name of the first element should be Numero Uno

  Scenario: Group statuses
  Given I am logged in to sekret at Coop
  Given I am about to get Coop for groups/1
  Given I am about to get Coop for groups
  When I ask Coop for the first group
  Then I should be given a Coop Group
  Then the group should have 6 statuses
  
  Scenario: Group statuses on certain dates
  Given I am logged in to sekret at Coop
  Given I am about to get Coop for groups/1/20090707
  Given I am about to get Coop for groups
  When I ask Coop for the first group on a certain date
  Then I should be given a Coop Group
  Then the group should have 3 statuses
  
  


