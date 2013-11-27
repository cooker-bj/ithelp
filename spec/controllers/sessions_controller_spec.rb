require 'spec_helper'


describe SessionsController do
  before(:each) do
    @user=User.new()
    @user.stub(:uid).and_return("1101")
    @user.stub(:salt).and_return("sadffs")

  end
  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "POST 'create'" do

    describe "get correct user name or password" do
      before(:each){ User.stub(:authenticate).with("david","security").and_return(@user)}
      it "sign in" do

       post :create,:session=>{:user_name=>'david',:password=>'security'}
       controller.signed_in?.should be_true
       controller.current_user.should==@user
    end

      it "redirect to root path when no location saved yet " do
        session[:return_to]=nil
        post :create,:session=>{:user_name=>'david',:password=>'security'}
       response.should redirect_to('/')
      end

      it "redirect to stored path " do
        session[:return_to]="sessions/new"
        post :create,:session=>{:user_name=>'david',:password=>'security'}
        response.should redirect_to('sessions/new')
      end
    end

    describe "get wrong user name or password"  do
      before(:each) {User.stub(:authenticate).and_return(nil)}
      it "render new when get wrong user name or password"  do

        post :create,:session=>{:user_name=>'david',:password=>'wrong_security'}
        response.should render_template("new")
      end

      it "set error message when get wrong" do

        post :create,:session=>{:user_name=>'david',:password=>'wrong_security'}
        flash[:notice].should== I18n.t(:login_with_wrong)
      end
    end
  end

  describe "DELETE 'destroy'" do
    before(:each)do
    controller.sign_in(@user)

    end

    it " sign out user" do
      delete :destroy
     controller.signed_in?.should be_false
    end

    it "redirect to login"   do
      delete :destroy
      response.should redirect_to "new"
    end
  end

end
