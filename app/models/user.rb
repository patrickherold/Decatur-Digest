class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # after_validation :geocode

  geocoded_by :current_sign_in_ip # can also be an IP address

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :birthdate, :income_cents, :disabled_veteran,
                  :name, :fb_first_name, :fb_middle_name, :fb_last_name, :fb_username, :fb_gener, :fb_picture,
                  :fb_locale, :fb_timezone, :fb_link, :fb_bio, :fb_cover, :fb_users_hometown, :workflow_manager_ids,
                  :organization_id, :role

  has_many :evaluations, class_name: "RSEvaluation", as: :source
  has_many :workflows
  has_many :appeal_reports
  belongs_to :organization
  has_and_belongs_to_many :workflow_managers,
                          :join_table => 'workflow_managers_users',
                          :foreign_key => 'manager_id',
                          :association_foreign_key => 'user_id',
                          :class_name => 'User'
  has_and_belongs_to_many :managed_users,
                          :join_table => 'workflow_managers_users',
                          :foreign_key => 'user_id',
                          :association_foreign_key => 'manager_id',
                          :class_name => 'User'

  #accepts_nested_attributes_for :lots, :reject_if => lambda { |a| a[:lot].blank? }, :allow_destroy => true

  validates_presence_of :username
  validates_uniqueness_of :username

  monetize :income_cents

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.username = auth.info.nickname
      user.fb_picture = auth.info.image
      user.fb_gener = auth.info.gender
      user.email = auth.info.email
      user.fb_users_hometown = auth.info.hometown
      user.fb_locale = auth.info.locale
      user.fb_bio = auth.info.bio
      user.fb_link = auth.info.link
    end
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  def voted_for?(lot)
    evaluations.where(target_type: lot.class, target_id: lot.id).present?
  end

  def total_votes
    LotVote.joins(:lot).where(lots: { user_id: self.id }).sum('value')
  end

  def managed_workflows
    Workflow.all.select { |w|
      !self.workflows.include?(w) && w.accessible_by(self)
    }
  end

  def role
    self[:role].try(:to_sym) || :user
  end

  def super_admin?
    role == :super_admin
  end

  def admin?
    organization && (role == :admin || super_admin?)
  end

  def user?
    organization && !(admin? || super_admin?)
  end

  def restricted?
    !organization
  end

  def assign(organization)
    update_attribute(:organization_id, organization.id)
  end

  def unassign!
    update_attributes({ :organization_id => nil, :role => super_admin? ? role : 'user' })
  end

  def self.unassigned
    User.all.reject(&:organization)
  end
end
