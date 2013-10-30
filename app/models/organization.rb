class Organization < ActiveRecord::Base
  belongs_to :parent_organization, :class_name => 'Organization'
  has_many :child_organizations, :class_name => 'Organization', :foreign_key => :parent_organization_id
  has_many :users
  has_many :lots

  attr_accessible :address, :name, :parent_organization_id, :parent_organization, :user_ids, :image,
                  :admin_ids, :lot_ids

  validates_presence_of :name

  has_attached_file :image

  def admins
    users.select(&:admin?)
  end

  def non_admins
    users.reject(&:admin?)
  end

  def user_ids
    users.collect(&:id)
  end

  def admin_ids
    admins.collect(&:id)
  end

  def admin_ids=(ids)
    ids.reject!(&:blank?)
    ids.each { |i|
      u = User.find_by_id(i)
      next unless u
      u.update_attribute(:organization_id, self.id)
      u.update_attribute(:role, :admin) unless u.super_admin?
    }
    reload unless new_record?
    users.each { |u|
      u.update_attribute(:role, ids.collect(&:to_i).include?(u.id) ? :admin : :user) unless u.super_admin?
    }
  end

  def lot_ids
    lots.collect(&:id)
  end

  def recursive_lots
    (lots + child_organizations.collect(&:lots).flatten).uniq
  end
end
