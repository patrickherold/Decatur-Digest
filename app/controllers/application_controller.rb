class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
  end
  

  def after_sign_up_path_for(resource)
  return request.env['omniauth.origin'] || session[:return_to] 
  end

end
