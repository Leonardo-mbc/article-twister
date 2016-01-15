class UsersController < ApplicationController
  include WordProcessor
  include Profiles

  def profile_update
    update()
  end

  def instant_profile_update
    instant_update()
  end

  def destroy
    session[:user] = nil
    redirect_to :controller => "/log", :action => "in"
  end
end
