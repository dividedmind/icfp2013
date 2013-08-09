class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :ensure_auth
  
  def ensure_auth
    render text: "Please provide valid ?auth", status: :unauthorized unless params[:auth] == ENV['ICFP_AUTH_KEY']
  end
  
  # Just proxy the request.
  def proxy
    render_response call_oracle
  end
  
  protected
  def call_oracle
    response = Oracle.call method: request.method.downcase.to_sym,
      path: params[:path],
      auth: params[:auth],
      payload: request.body
  end
  
  def render_response response
    render text: response.body, status: response.code, content_type: response.headers[:content_type]
  end
end
