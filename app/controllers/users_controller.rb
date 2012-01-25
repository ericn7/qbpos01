class UsersController < ApplicationController
  layout 'login'
  before_filter :login_required, :only => [:show]

  def new
	@user = User.new
  end

  def create
	@user = User.new(params[:user])
	if @user.save
	  redirect_back_or_default root_path, :notice => "Welcome #{@user.first_name}!"
	else
	  render :action => :new
	end
  end

  def show
	@user = current_user
	render :layout => "application"
  end

  def cancel
	render :layout => "application"
  end
end
