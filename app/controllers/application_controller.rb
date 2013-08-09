class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :ensure_auth
  
  def ensure_auth
    render text: "Please provide valid ?auth", status: :unauthorized unless params[:auth] == ENV['ICFP_AUTH_KEY']
  end
end
