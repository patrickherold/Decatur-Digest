class Workflow < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :lots
  has_and_belongs_to_many :managers,
                          :join_table => 'managers_workflows',
                          :foreign_key => 'user_id',
                          :association_foreign_key => 'workflow_id',
                          :class_name => 'User'
  has_and_belongs_to_many :global_managers,
                          :join_table => 'workflow_managers_users',
                          :foreign_key => 'manager_id',
                          :association_foreign_key => 'user_id',
                          :class_name => 'User'

  attr_accessible :description, :name, :user_id, :user, :lots, :lot_ids, :manager_ids

  serialize :status

  validates_presence_of :name, :user

  def accessible_by(u)
    managers.include?(u) || user == u
  end

  def status_by_lot(lot)
    status.select { |s|
      s[:lot_id].to_i == lot.id
    }.sort_by { |s| s[:timestamp] }.reverse
  end

  def status
    (self[:status] || []).map { |s|
      s[:user] = User.find_by_id(s[:user])
      s[:lot] = Lot.find_by_id(s[:lot_id])
      s
    }
  end

  def status=(val)
    super
  end

  def managers
    super.empty? ?
        user.workflow_managers :
        super
  end

  def manager_ids
    super.empty? ?
        user.workflow_managers.collect(&:id) :
        super
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      workflow.lot.each do |lot|
        csv << lot.attributes.values_at(*column_names)
      end
    end
  end
end