Feature: Projects
  In order to perform crud operations on projects
  As an API user
  I want it to be easy!
  
  Scenario: /projects
  Given I am logged in to sekret at Harvest
  Given I am about to get harvest for projects
  When I ask Harvest for all projects
  Then the name of the first element should be The Project
     
  Scenario: /projects/1
  Given I am logged in to sekret at Harvest
  Given I am about to get harvest for projects/1
  When I ask Harvest for the first project
  Then the name should be The Project