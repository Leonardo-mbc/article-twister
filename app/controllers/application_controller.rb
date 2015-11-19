class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #before_filter :login_check
  protect_from_forgery with: :exception

  private

  def login_check
    c = params[:controller]
    a = params[:action]
    if (c != "log" && a != "in") && (c != "users")
      if session[:userID].blank?
        redirect_to :controller => "log", :action => "in"
      end
    end
  end
end
