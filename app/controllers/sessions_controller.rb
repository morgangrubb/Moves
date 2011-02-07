class SessionsController < ApplicationController
  skip_before_filter :require_login

  layout 'single'

  def new
    @user = User.new
  end

  def create
    user = User.authenticate params[:user][:email], params[:user][:password]
    if user
      session[:user_id] = user.id
      redirect_to root_url
    else
      @user = User.new :email => params[:user][:email]
      flash.now[:error] = "Invalid email or password"  
      render "new"  
    end
  end
  
  def destroy  
    session[:user_id] = nil  
    redirect_to root_url, :notice => "Logged out!"  
  end

end
