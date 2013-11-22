class AddLatLonCorrectedToLots < ActiveRecord::Migration
  def change
    add_column :lots, :lat_lon_corrected, :boolean
  end
end
