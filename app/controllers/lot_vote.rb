class LotVote < ActiveRecord::Base
  attr_accessible :value, :lot, :lot_id

  belongs_to :lot
  belongs_to :user

  validates_uniqueness_of :lot_id, scope: :user_id
  validates_inclusion_of :value, in: [1, 0, -1]
  validate :ensure_not_author

  def ensure_not_author
    errors.add :user_id, "is the owner of the lot" if lot.user_id == user_id
  end
end

