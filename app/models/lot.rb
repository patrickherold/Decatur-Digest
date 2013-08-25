class Lot < ActiveRecord::Base

  attr_accessible :latitude, :longitude, :mailing_latitude, :mailing_longitude, :customer_id, :municipal_id, :name, :property_map_address, :property_street_name
  geocoded_by :property_map_address   # can also be an IP address
  after_validation :geocode          # auto-fetch coordinates
  acts_as_gmappable
  has_reputation :votes, source: :user, aggregated_by: :sum
  has_many :portfolios
  has_many :users, :through => :portfolios

  include ModelStats

  UNRANSACKABLE_ATTRIBUTES = ["id", "tax_district", "created_at", "modified_at", "updated_at", "tax_year", "customer_id", "municipal_id", "tax_paid", "tax_dispute"]
  def self.ransackable_attributes(auth_object = nil)
      %w( parcel_id property_map_address owner co_owner appraised_value land_value building_value appeal_value homestead zoning ) + _ransackers.keys
  end

  has_many :lot_votes

  def self.by_votes
    select('lots.*, coalesce(value, 0) as votes').
    joins('left join lot_votes on lot_id=lots.id').
    order('votes desc')
  end
  
  scope :commercial_property, where("zoning = ?", 'C3')
    
  scope :appeal_property, where("appeal_value >= ?", '1')

  scope :appraised_property, where("appeal_value < ?", '1')

  scope :all_commericial_appeal, commercial_property.appeal_property

  scope :all_commericial_appraised, commercial_property.appraised_property


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

  def votes
    read_attribute(:votes) || lot_votes.sum(:value)
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
    full_appeal unless appeal_value.nil?
  end
  
  def full_appeal
    appeal_value * 2.5
  end

  def full_taxable
    taxable * 2.5
  end
  
  def total_tax
    city_tax + school_tax + capital_tax + bond_tax + dda_tax
  end
  
  def appraised_tax
    city_tax_ap + school_tax_ap + capital_tax_ap + bond_tax_ap + dda_tax_ap
  end
  
  def lost_to_appeal
    lost_to_appeal = appraised_tax - total_tax
  end

  def city_tax_ap
    if general_homestead.present?
      appraised_appraised - city_tax_exemption
    elsif senior_65_school_homestead.present?
      appraised_appraised - city_tax_exemption
    elsif senior_62_school_homestead.present?
      appraised_appraised - city_tax_exemption
    elsif senior_62_low_income_school_homestead.present?
      appraised_appraised - city_tax_exemption
    elsif senior_70_school_homestead.present?
      appraised_appraised - city_tax_exemption
    elsif senior_80_school_homestead.present?
      appraised_appraised - city_tax_exemption
    end
    appraised_appraised * 0.0102 * 0.5
  end
  
  def school_tax_ap
    if general_homestead.present?
      appraised_appraised - school_tax_exemption
    elsif senior_65_school_homestead.present?
      appraised_appraised - school_tax_exemption
    elsif senior_62_school_homestead.present?
      appraised_appraised - school_tax_exemption
    elsif senior_62_low_income_school_homestead.present?
      appraised_appraised - school_tax_exemption
    elsif senior_70_school_homestead.present?
      appraised_appraised - school_tax_exemption
    elsif senior_80_school_homestead.present?
      appraised_appraised - school_tax_exemption
    end
    appraised_appraised * 0.0209 * 0.5
  end
  
  def capital_tax_ap
    if general_homestead.present?
      appraised_appraised - capital_tax_exemption
    elsif senior_65_school_homestead.present?
      appraised_appraised - capital_tax_exemption
    elsif senior_62_school_homestead.present?
      appraised_appraised - capital_tax_exemption
    elsif senior_62_low_income_school_homestead.present?
      appraised_appraised - capital_tax_exemption
    elsif senior_70_school_homestead.present?
      appraised_appraised - capital_tax_exemption
    elsif senior_80_school_homestead.present?
      appraised_appraised - capital_tax_exemption
    end
    appraised_appraised * 0.001 * 0.5
  end
  
  def bond_tax_ap
    if general_homestead.present?
      appraised_appraised - bond_tax_exemption
    elsif senior_65_school_homestead.present?
      appraised_appraised - bond_tax_exemption
    elsif senior_62_school_homestead.present?
      appraised_appraised - bond_tax_exemption
    elsif senior_62_low_income_school_homestead.present?
      appraised_appraised - bond_tax_exemption
    elsif senior_70_school_homestead.present?
      appraised_appraised - bond_tax_exemption
    elsif senior_80_school_homestead.present?
      appraised_appraised - bond_tax_exemption
    end
    appraised_appraised * 0.00142 * 0.5
  end
  
  def dda_tax_ap
    if general_homestead.present?
      appraised_appraised - dda_tax_exemption
    elsif senior_65_school_homestead.present?
      appraised_appraised - dda_tax_exemption
    elsif senior_62_school_homestead.present?
      appraised_appraised - dda_tax_exemption
    elsif senior_62_low_income_school_homestead.present?
      appraised_appraised - dda_tax_exemption
    elsif senior_70_school_homestead.present?
      appraised_appraised - dda_tax_exemption
    elsif senior_80_school_homestead.present?
      appraised_appraised - dda_tax_exemption
    end
    appraised_appraised * 0.0038 * 0.5
  end


  def city_tax_rate
    0.0102
  end

  def school_tax_rate
    0.0209
  end

  def capital_tax_rate
    0.001
  end

  def bond_tax_rate
    0.00142
  end

  def dda_tax_rate
    0.0038
  end

  def city_tax
    if general_homestead.present?
      full_taxable - city_tax_exemption
    elsif senior_65_school_homestead.present?
      full_taxable - city_tax_exemption
    elsif senior_62_school_homestead.present?
      full_taxable - city_tax_exemption
    elsif senior_62_low_income_school_homestead.present?
      full_taxable - city_tax_exemption
    elsif senior_70_school_homestead.present?
      full_taxable - city_tax_exemption
    elsif senior_80_school_homestead.present?
      full_taxable - city_tax_exemption
    end
    full_taxable * 0.0102 * 0.5
  end
  
  def school_tax
    if general_homestead.present?
      full_taxable - school_tax_exemption
    elsif senior_65_school_homestead.present?
      full_taxable - school_tax_exemption
    elsif senior_62_school_homestead.present?
      full_taxable - school_tax_exemption
    elsif senior_62_low_income_school_homestead.present?
      full_taxable - school_tax_exemption
    elsif senior_70_school_homestead.present?
      full_taxable - school_tax_exemption
    elsif senior_80_school_homestead.present?
      full_taxable - school_tax_exemption
    end
    full_taxable * 0.0209 * 0.5
  end
  
  def capital_tax
    if general_homestead.present?
      full_taxable - capital_tax_exemption
    elsif senior_65_school_homestead.present?
      full_taxable - capital_tax_exemption
    elsif senior_62_school_homestead.present?
      full_taxable - capital_tax_exemption
    elsif senior_62_low_income_school_homestead.present?
      full_taxable - capital_tax_exemption
    elsif senior_70_school_homestead.present?
      full_taxable - capital_tax_exemption
    elsif senior_80_school_homestead.present?
      full_taxable - capital_tax_exemption
    end
    full_taxable * 0.001 * 0.5
  end
  
  def bond_tax
    if general_homestead.present?
      full_taxable - bond_tax_exemption
    elsif senior_65_school_homestead.present?
      full_taxable - bond_tax_exemption
    elsif senior_62_school_homestead.present?
      full_taxable - bond_tax_exemption
    elsif senior_62_low_income_school_homestead.present?
      full_taxable - bond_tax_exemption
    elsif senior_70_school_homestead.present?
      full_taxable - bond_tax_exemption
    elsif senior_80_school_homestead.present?
      full_taxable - bond_tax_exemption
    end
    full_taxable * 0.00142 * 0.5
  end
  
  def dda_tax
    if general_homestead.present?
      full_taxable - dda_tax_exemption
    elsif senior_65_school_homestead.present?
      full_taxable - dda_tax_exemption
    elsif senior_62_school_homestead.present?
      full_taxable - dda_tax_exemption
    elsif senior_62_low_income_school_homestead.present?
      full_taxable - dda_tax_exemption
    elsif senior_70_school_homestead.present?
      full_taxable - dda_tax_exemption
    elsif senior_80_school_homestead.present?
      full_taxable - dda_tax_exemption
    end
    full_taxable * 0.0038 * 0.5
  end

 
  def city_tax_exemption 
    if general_homestead.present? 
      20000
    elsif senior_62_school_homestead.present?
      70000
    elsif senior_62_low_income_school_homestead.present?
      70000
    elsif senior_65_school_homestead.present?
      0
    elsif senior_70_school_homestead.present?
      100000
    elsif senior_80_school_homestead.present?
      100000
    else
      0
    end
  end
     
  def school_tax_exemption 
    if general_homestead.present? 
      20000
    elsif senior_62_school_homestead.present?
      70000
    elsif senior_62_low_income_school_homestead.present?
      70000
    elsif senior_65_school_homestead.present?
      0
    elsif senior_70_school_homestead.present?
      100000
    elsif senior_80_school_homestead.present?
      100000
    else
      0
    end
  end
  
  def capital_tax_exemption 
    if general_homestead.present? 
      20000
    elsif senior_62_school_homestead.present?
      70000
    elsif senior_62_low_income_school_homestead.present?
      70000
    elsif senior_65_school_homestead.present?
      0
    elsif senior_70_school_homestead.present?
      100000
    elsif senior_80_school_homestead.present?
      100000
    else
      0
    end
  end
  
  def bond_tax_exemption 
    if general_homestead.present? 
      20000
    elsif senior_62_school_homestead.present?
      70000
    elsif senior_62_low_income_school_homestead.present?
      70000
    elsif senior_65_school_homestead.present?
      1000
    elsif senior_70_school_homestead.present?
      70000
    elsif senior_80_school_homestead.present?
      70000
    else
      0
    end
  end
 
  def dda_tax_exemption 
    if general_homestead.present? 
      20000
    elsif senior_62_school_homestead.present?
      70000
    elsif senior_62_low_income_school_homestead.present?
      70000
    elsif senior_65_school_homestead.present?
      1000
    elsif senior_70_school_homestead.present?
      70000
    elsif senior_80_school_homestead.present?
      70000
    else
      0
    end
  end
  
  def no_homestead
    if homestead.nil? || homestead.empty?
    end
  end
  
  def general_homestead
    if homestead == "H1F" || homestead == "LDF" || homestead == "H6DF" || homestead == "H6D" || homestead == "H0"
      city_tax_exemption = 20000
      school_tax = 0
      capital_tax = 20000
      dda_tax = 20000
    end
  end
  
  def senior_62_school_homestead
    if homestead == "H5F"
      city_tax_exemption = 70000
      school_tax = 50000
      capital_tax = 70000
      dda_tax = 70000
    end
  end
  
  def senior_62_low_income_school_homestead
    if homestead == "H6F"
      city_tax_exemption = 70000
      school_tax = 60000
      capital_tax = 70000
      dda_tax = 70000
    end
  end
  
  def senior_65_school_homestead
    if homestead == "H1"
      city_tax_exemption = 1000
      school_tax = 0
      capital_tax = 1000
      dda_tax = 1000
    end
  end
  
  def senior_70_school_homestead
    if homestead == "H6F" || homestead == "H5F" || homestead == "H1S" || homestead == "H6I" || homestead == "H6IF" || homestead == "H5S"
      city_tax_exemption = 70000
      school_tax = 100000
      capital_tax = 70000
      dda_tax = 70000
    end
  end
  
  def senior_80_school_homestead
    if homestead == "H5S"
      city_tax_exemption = @lot.appraised_appraised
      school_tax = 100000
      capital_tax = 70000
      dda_tax = 70000
    end
  end

  def gmaps4rails_infowindow
    "<h4>#{self.owner}</h4>" << "#{property_map_address}"
  end

  def gmaps4rails_address
    "#{self.property_map_address}" 
  end


  def property_street_and_number
    [property_street_number, property_street_name_prefix, property_street_name, property_street_type].join(" ")
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