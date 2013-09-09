class Address < ActiveRecord::Base
  attr_accessible :street_sub_number, :street_name_prefix, :street_number, :street_name, :street_type, :street_type_postfix, :street_suite, :city, :state, :zip, :zip_plus_4, :lot_attributes, :latitude, :longitude
  geocoded_by :map_address
  after_validation :geocode
  belongs_to :lot
  
  scope :property_address, where("property_address=true")
  
  acts_as_gmappable



  def gmaps4rails_infowindow
    "<h4>#{@owner.owner}</h4>" << "<h4>#{map_address}</h4>"
  end



  def gmaps4rails_address
    "#{self.map_address}" 
  end

  def street
    if street_type_postfix.present?
      [street_sub_number, street_name_prefix, street_number, street_name, street_type, street_type_postfix].join(" ")
    else
      [street_sub_number, street_name_prefix, street_number, street_name, street_type].join(" ")
    end
  end

  
  def map_address
    [street, city, state, zip].join(", ")
  end
  
  def full_address
    if street_suite.present?
      [street, street_suite, city, state, zip].join(", ")
    else
      [street, city, state, zip].join(", ")
    end
  end
  
  
  
  
end
