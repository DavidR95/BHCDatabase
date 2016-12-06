class SessionsController < ApplicationController

  skip_before_action :require_login

  def new
    if logged_in?
      redirect_to root_url if logged_in?
      flash[:info] = "You are already logged in."
    end
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end
  
  def destroy
    log_out if logged_in?
    redirect_to login_path
  end
end
