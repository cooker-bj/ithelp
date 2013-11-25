class SessionsController < ApplicationController

  respond_to :html,:json
  def new

  end

  def create
    if (user=User.authenticate(params[:session][:user_name],params[:session][:password]))
      sign_in(user)
      redirect_back_or_default
    else
      flash[:notice]=t(:login_with_wrong)
      render('new')
    end

  end

  def destroy
    sign_out
    redirect_to "new"
  end
end
