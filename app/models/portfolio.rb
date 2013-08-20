class Portfolio < ActiveRecord::Base
  belongs_to :lot
  belongs_to :user
  
  attr_accessible :follow_type, :lot_relationship, :lot_residency
  validates :user_id, :lot_id
end
