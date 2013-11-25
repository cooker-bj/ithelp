require 'spec_helper'

describe "GET sign_in" do
  it "should routed to /sessions/new"  do
    get('/sign_in').should  route_to 'sessions#new'
  end

end
