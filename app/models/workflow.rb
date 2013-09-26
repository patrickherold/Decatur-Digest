class Workflow < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :lots
  has_and_belongs_to_many :managers,
                          :join_table => 'managers_workflows',
                          :foreign_key => 'user_id',
                          :association_foreign_key => 'workflow_id',
                          :class_name => 'User'

  attr_accessible :description, :name, :user_id, :user, :lots, :lot_ids, :managers, :manager_ids

  validates_presence_of :name, :user

  def accessible_by(u)
    managers.include?(u) || user == u
  end
end
