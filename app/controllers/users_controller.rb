class UsersController < ApplicationController
  include WordProcessor
  include Profiles

  def profile_update
    update()
  end

  def instant_profile_update
    instant_update()
  end
end
