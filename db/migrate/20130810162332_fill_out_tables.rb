class FillOutTables < ActiveRecord::Migration
  def change
    add_column :lots, :parcel_id, :text
    add_column :lots, :homestead, :text

    add_column :lots, :land_value, :integer
    add_column :lots, :building_value, :integer
    add_column :lots, :appraised_value, :integer
    add_column :lots, :appeal_value, :integer
    add_column :lots, :taxable, :integer

    add_column :lots, :zoning, :text
    add_column :lots, :tax_year, :integer

    add_column :lots, :property_street_sub_number, :text
    add_column :lots, :property_street_number, :int
    add_column :lots, :property_street_name_prefix, :text
    add_column :lots, :property_street_name, :text
    add_column :lots, :property_street_type, :text
    add_column :lots, :property_street_type_postfix, :text
    add_column :lots, :property_street_suite, :text
    add_column :lots, :property_city, :text
    add_column :lots, :property_state, :text
    add_column :lots, :property_zip, :integer
    add_column :lots, :property_zip_plus_four, :integer

    add_column :lots, :owner, :text
    add_column :lots, :co_owner, :text
    add_column :lots, :in_care_of, :text

    add_column :lots, :mailing_street_number, :text
    add_column :lots, :mailing_street_name_prefix, :text
    add_column :lots, :mailing_street_name, :text
    add_column :lots, :mailing_street_type, :text
    add_column :lots, :mailing_street_type_postfix, :text
    add_column :lots, :mailing_street_suite, :text
    add_column :lots, :mailing_city, :text
    add_column :lots, :mailing_state, :text
    add_column :lots, :mailing_zip, :integer
    add_column :lots, :mailing_zip_plus_four, :integer

    add_column :lots, :latitude, :float
    add_column :lots, :longitude, :float
    add_column :lots, :mailing_latitude, :float
    add_column :lots, :mailing_longitude, :float

    add_column :lots, :customer_id, :integer
    add_column :lots, :municipal_id, :integer
    
  end
end
