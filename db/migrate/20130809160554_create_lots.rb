class CreateLots < ActiveRecord::Migration
  def change
    create_table :lots do |t|
      t.string :tax_district

      t.timestamps
    end
  end
end
