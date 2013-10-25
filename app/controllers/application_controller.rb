class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
  end

  def show
  end

  def about
    generic
  end

  def contact
    generic
  end

  def after_sign_up_path_for(resource)
    return request.env['omniauth.origin'] || session[:return_to]
  end

  private

  def verify_super_admin!
    unless current_user.super_admin?
      flash[:alert] = "You don't have sufficient permissions to access this section"
      redirect_to '/'
    end
  end
end
