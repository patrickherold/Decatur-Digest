class FillOutPortfolio < ActiveRecord::Migration
  def up
    create_table 'portfolio' do |t|
      t.column :user_id, :integer
      t.column :lot_id, :integer
      t.column :follow_type, :string
      t.column :lot_relationship, :string
      t.column :lot_residency, :string
      t.timestamps
    end
  end
end
