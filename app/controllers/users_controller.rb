class UsersController < ApplicationController
  include WordProcessor

  def profile_update
    prof = Hash.new(0)

    current_user.user_discriminations.each do |rate|
      if 0 < rate.sign
        wc_hash(rate.news.news_id).each do |wc|
          prof[wc[:word]] += wc[:count]
        end
      elsif rate.sign < 0
        wc_hash(rate.news.news_id).each do |wc|
          prof[wc[:word]] -= wc[:count]
        end
      end
    end

    save_article prof, current_user.id, 'user_prof' if prof.present?
  end

  def instant_profile_update
    public_dir = "#{Rails.root}/public"
    prof = Hash.new(0)

    f = File.open("#{public_dir}/user_profiles/#{current_user.id}.txt", 'r').each_line do |line|
      items = line.split(',')
      prof[items.first] = items.second.to_i
    end
    f.close

    prof[params[:word]] += params[:score].to_i * 50
    save_article prof, current_user.id, 'user_prof' if prof.present?
  end
end
