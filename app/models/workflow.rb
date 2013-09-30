class Workflow < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :lots

  attr_accessible :description, :name, :user_id, :user, :lots, :lot_ids

  serialize :status

  validates_presence_of :name, :user

  def accessible_by(u)
    managers.include?(u) || user == u
  end

  def lots_with_status
    lots.map {|lot|
      st = status_by_lot(lot)
      {
          :lot => lot,
          :status => st ? st[:status] : nil,
          :message => st ? st[:message] : nil
      }
    }
  end

  def status_by_lot(lot)
    status.select {|s|
      s[:lot_id].to_i == lot.id
    }.first
  end

  def status
    (self[:status] || []).map {|s|
      s[:user] = User.find_by_id(s[:user])
      s[:lot] = Lot.find_by_id(s[:lot_id])
      s
    }
  end

  def status=(val)
    super
  end

  def managers
    User.all.select {|u| u.managed_workflows.include?(self) }.uniq.reject {|u| user == u }
  end
end