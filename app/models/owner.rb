class Owner < ActiveRecord::Base
  attr_accessible :lot_id, :name, :lot_attributes
  
  belongs_to :lot
  
  UNRANSACKABLE_ATTRIBUTES = ["name", "created_at", "modified_at", "updated_at","customer_id", "address_id", "user_id"]
  
  
end
