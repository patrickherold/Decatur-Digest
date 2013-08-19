class AddFacebookFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :fb_name, :string
    add_column :users, :fb_first_name, :string
    add_column :users, :fb_last_name, :string
    add_column :users, :fb_middle_name, :string
    add_column :users, :fb_gener, :string
    add_column :users, :fb_locale, :string
    add_column :users, :fb_link, :string
    add_column :users, :fb_username, :string
    add_column :users, :fb_timezone, :string
    add_column :users, :fb_bio, :string
    add_column :users, :fb_birthday, :string
    add_column :users, :fb_cover, :string
    add_column :users, :fb_email, :string
    add_column :users, :fb_users_hometown, :string
    add_column :users, :fb_picture, :string
  end
end
