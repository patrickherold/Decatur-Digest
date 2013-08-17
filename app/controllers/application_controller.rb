class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
  end
  
  def after_sign_in_path_for(resource_or_scope)
    if request.env['omniauth.origin']
       request.env['omniauth.origin']
    end
  end
  
  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  
end
