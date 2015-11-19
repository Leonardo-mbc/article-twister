class LogController < ApplicationController
  def in
  end

  def out
    session[:user] = nil
    redirect_to :root
  end
end
