class AppealReport < ActiveRecord::Base
  belongs_to :user

  attr_accessible :original_address, :similar_by_building, :similar_by_land, :user

  serialize :similar_by_building
  serialize :similar_by_land

  validates_presence_of :user, :original_address

  def similar_by_building
    (self[:similar_by_building] || []).map {|i|
      Lot.find_by_id(i)
    }.compact
  end

  def similar_by_land
    (self[:similar_by_land] || []).map {|i|
      Lot.find_by_id(i)
    }.compact
  end
end
