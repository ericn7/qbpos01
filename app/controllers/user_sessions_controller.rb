class UserSessionsController < ApplicationController
  layout 'login'
  before_filter :login_required, :only => [:destroy]
  before_filter :logout_required, :only => [:new, :create]

  def new
	@user_session = UserSession.new
  end

  def create
	@user_session = UserSession.new(params[:user_session])
	if @user_session.save
	  flash[:notice] = "Welcome back #{@user_session.record.first_name}!"
	  redirect_back_or_default root_path
	else
	  render :action => :new
	end
  end

  def destroy
	current_user_session.destroy
	redirect_back_or_default login_path, :notice => "You have successfully logged out!"
  end
end
