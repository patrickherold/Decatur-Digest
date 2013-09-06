class Portfolio < ActiveRecord::Base
  has_many :lots
  belongs_to :user
  
  scope :portfolio_property, where("user_id = ?", @current_user.id)

end
