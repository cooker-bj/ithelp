Given(/^I am on sign in page$/) do
  visit('/sign_in')
end

When(/^I fill user name with "(.*?)"$/) do |arg1|
 fill_in("session_user_name",:with=>arg1)
end

When(/^fill password with "(.*?)"$/) do |arg1|
  fill_in("session_password",:with=>arg1)
end

When(/^click sign up button$/) do
  click_button('sign up')
end

Then(/^I will see "(.*?)"$/) do |arg1|
 page.should have_content(arg1)
end
