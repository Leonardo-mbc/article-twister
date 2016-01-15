class LogController < ApplicationController
  def in
    @users = User.all
  end

  def force
    session[:user] = User.find(params[:id].to_i)
  end
end
