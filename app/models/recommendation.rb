class Recommendation < ActiveRecord::Base
  belongs_to :user
  has_many :recommendation_sources
end
