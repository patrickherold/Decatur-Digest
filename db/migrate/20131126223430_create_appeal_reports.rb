class CreateAppealReports < ActiveRecord::Migration
  def change
    create_table :appeal_reports do |t|
      t.integer :user_id
      t.text :similar_by_building
      t.text :similar_by_land
      t.string :original_address

      t.timestamps
    end
  end
end
