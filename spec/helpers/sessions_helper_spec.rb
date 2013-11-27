require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the SessionsHelper. For example:
#
# describe SessionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe SessionsHelper do
  before(:each) do
    @user=User.new()
    @user.stub(:uid).and_return("1101")
    @user.stub(:salt).and_return("3dsf4")
  end
  describe "sign_in user" do

    it "fills session with user.id and user.salt" do
        sign_in(@user)
        session[:remember_token].should== ['1101',"3dsf4"]
    end

    it "creates current_user" do
      sign_in(@user)
      current_user.should== @user
    end
  end

  describe "current_user" do
       it "set current_user" do
       self.current_user= @user
        @current_user.should==@user
       end
    it "get current_user"  do
        @current_user=@user
         current_user.should==@user
    end

  end

  describe "signed_in?" do
    it "return true when user sign in"  do
         helper.sign_in(@user)
         helper.signed_in?.should be_true
    end

    it "return false when user doesn't sign in"  do
         helper.signed_in?.should be_false
    end

  end



end
