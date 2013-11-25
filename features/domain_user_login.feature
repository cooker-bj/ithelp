Feature: login
  For security reason, the system only accepts permitted user
  and for keeping authenticated system simple, we need use domain system for authenticating
  In order to use the system
  AS a Domain user
  I need to login system first

Scenario:  Domain user Login with correct name and password
 Given  I am on sign in page
 When   I fill user name with "David"
 And    fill password with "security"
 And    click sign up button
Then    I will see "welcome David"


Scenario: Domain user login with wrong name or password
  Given I am on sign in page
  When I fill user name with "David"
  And  fill password with "wrong word"
  And  click sign up button
  Then I will see "wrong name or password"
