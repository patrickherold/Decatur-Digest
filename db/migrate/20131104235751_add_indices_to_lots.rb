class AddIndicesToLots < ActiveRecord::Migration
  def change
    add_index :lots, :parcel_id, :length => { :parcel_id => 255 }
    add_index :lots, :tax_year
  end
end
