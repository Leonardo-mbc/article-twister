class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  require 'open-uri'
  before_filter :login_check
  protect_from_forgery with: :exception

  alias_method :devise_current_user, :current_user

  def current_user
    if session[:user].nil?
      nil
    else
      User.find(session[:user]["id"].to_i)
    end
  end

  private

  def login_check
    c = params[:controller]
    a = params[:action]
    if (c != "log" && a != "in") && (c != "users/omniauth_callbacks")
      if session[:user].blank?
        redirect_to :controller => "/log", :action => "in"
      end
    end
  end
end
