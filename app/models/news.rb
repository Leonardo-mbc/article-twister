class News < ActiveRecord::Base
  has_many :user_discriminations
  has_many :recommendation_sources

  def sign(user_id)
    ud = user_discriminations.where(user_id: user_id)
    if ud.present?
      ud.first.sign
    else
      nil
    end
  end

  def nps(user_id)
    ud = user_discriminations.where(user_id: user_id)
    if ud.present?
      ud.first.nps
    else
      nil
    end
  end
end
