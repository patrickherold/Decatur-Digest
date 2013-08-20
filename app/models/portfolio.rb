class Portfolio < ActiveRecord::Base
  belongs_to :lot
  belongs_to :user
end
