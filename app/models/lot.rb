class Lot < ActiveRecord::Base

  geocoded_by :property_map_address   # can also be an IP address
  after_validation :geocode          # auto-fetch coordinates
  acts_as_gmappable
  has_reputation :votes, source: :user, aggregated_by: :sum

  UNRANSACKABLE_ATTRIBUTES = ["id", "tax_district", "created_at", "modified_at", "updated_at", "tax_year", "customer_id", "municipal_id", "tax_paid", "tax_dispute"]

  has_many :lot_votes

  def self.by_votes
    select('lots.*, coalesce(value, 0) as votes').
    joins('left join lot_votes on lot_id=lots.id').
    order('votes desc')
  end

  def votes
    read_attribute(:votes) || lot_votes.sum(:value)
  end

  def owner_last_name
    self.owner.split(' ')[0..0].join(' ')
  end
  
  def owner_first_name
    self.owner.split[1..11].join(" ")
  end

  def owners_name
    owner_first_name << " " << owner_last_name
  end

  def co_owner_last_name
    self.co_owner.split(' ')[0..0].join(' ')
  end
  
  def co_owner_first_name
    self.co_owner.split[1..11].join(" ")
  end

  def co_owners_name
    co_owner_first_name << " " << co_owner_last_name
  end

  def appraised_appraised
    appraised_value unless appraised_value.nil?
  end
  
  def appraised_currency
    number_to_currency(appraised_appraised, :unit => "$").to_s
  end
  
  
  def building_appraised
    building_value unless building_value.nil?
  end
  
  def land_appraised
    land_value unless land_value.nil?
  end
  
  def appeal_appraised
    appeal_value unless appeal_value.nil?
  end
##########################################################   Property Map Address not working, could be due to definitions or routes
  def self.ransackable_attributes(auth_object = nil)
      %w( property_map_address owner co_owner appraised_value land_value building_value taxable zoning ) + _ransackers.keys
  end

  def gmaps4rails_infowindow
    "<h4>#{self.owner}</h4>" << "#{property_map_address}"
  end

  def gmaps4rails_address
    "#{self.property_map_address}" 
  end

  def property_street
    if property_street_type_postfix.present?
      [property_street_sub_number, property_street_number, property_street_name_prefix, property_street_name, property_street_type, property_street_type_postfix].join(" ")
    else
      [property_street_sub_number, property_street_number, property_street_name_prefix, property_street_name, property_street_type].join(" ")
    end
  end
  
  def property_map_address
    [property_street, property_city, property_state, property_zip].join(", ")
  end

  def property_full_address
    if property_street_suite.present?
      [property_street, property_street_suite, property_city, property_state, property_zip].join(", ")
    else
      [property_street, property_city, property_state, property_zip].join(", ")
    end
  end
  
  def mailing_street
    if mailing_street_type_postfix.present?
      [mailing_street_number, mailing_street_name_prefix, mailing_street_name, mailing_street_type, mailing_street_type_postfix].join(" ")
    else
      [mailing_street_number, mailing_street_name_prefix, mailing_street_name, mailing_street_type].join(" ")
    end
  end
  
  def mailing_map_address
    [mailing_street, mailing_city, mailing_state, mailing_zip].join(", ")
  end

  def mailing_full_address
    if mailing_street_suite.present?
      [mailing_street, mailing_street_suite, mailing_city, mailing_state, mailing_zip].join(", ")
    else
      [mailing_street, mailing_city, mailing_state, mailing_zip].join(", ")
    end
  end
  

end