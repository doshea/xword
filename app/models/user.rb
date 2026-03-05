# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  first_name             :string(18)
#  last_name              :string(24)
#  username               :string(16)       not null
#  email                  :string(254)      not null
#  image                  :text
#  location               :string(255)
#  is_admin               :boolean          default(FALSE)
#  password_digest        :string(255)
#  auth_token             :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  verified               :boolean          default(FALSE)
#  verification_token     :string
#

class User < ApplicationRecord
  has_secure_password

  has_many :crosswords, inverse_of: :user, dependent: :nullify
  has_many :unpublished_crosswords, inverse_of: :user, dependent: :nullify
  has_many :comments, inverse_of: :user, dependent: :nullify
  has_many :solutions, inverse_of: :user, dependent: :destroy
  has_many :clues, inverse_of: :user, dependent: :nullify

  has_many :favorite_puzzles, inverse_of: :user, dependent: :destroy
  has_many :favorites, through: :favorite_puzzles, source: :crossword

  has_many :solution_partnerings, inverse_of: :user, dependent: :destroy
  has_many :team_solutions, through: :solution_partnerings, source: :solution

  # Bidirectional self-join: each friendship is stored once, queried from both sides.
  has_many :friendship_ones, :class_name => 'Friendship', :foreign_key => :friend_id
  has_many :friend_ones, class_name: 'User', through: :friendship_ones
  has_many :friendship_twos, :class_name => 'Friendship', :foreign_key => :user_id
  has_many :friend_twos, class_name: 'User', through: :friendship_twos

  has_many :notifications, inverse_of: :user, dependent: :destroy
  has_many :triggered_notifications, class_name: 'Notification',
           foreign_key: :actor_id, inverse_of: :actor, dependent: :destroy

  has_many :sent_friend_requests, class_name: 'FriendRequest', foreign_key: :sender_id, dependent: :delete_all
  has_many :received_friend_requests, class_name: 'FriendRequest', foreign_key: :recipient_id, dependent: :delete_all

  before_create { generate_token(:auth_token); generate_token(:verification_token); }

  include PgSearch::Model
  pg_search_scope :starts_with,
                  against: [:first_name, :last_name, :username],
                  using: {
                    tsearch: {prefix: true}
                  }

  pg_search_scope :admin_search,
                against: [:id, :first_name, :last_name, :username, :email],
                using: {
                  tsearch: {prefix: true}
                }

  self.per_page = 50

  mount_uploader :image, AccountPicUploader

  MIN_PASSWORD_LENGTH = 5
  MAX_PASSWORD_LENGTH = 16
  validates :password,
    confirmation: true,
    allow_blank: true,
    length: { minimum: MIN_PASSWORD_LENGTH, maximum: MAX_PASSWORD_LENGTH, message: ": Should be #{MIN_PASSWORD_LENGTH}-#{MAX_PASSWORD_LENGTH} characters" }

  validates_presence_of :password, on: :create
  validates_presence_of :password, on: :change_password

  MIN_EMAIL_LENGTH = 5
  MAX_EMAIL_LENGTH = 254 #hard-coded in database
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email,
    presence: true,
    uniqueness: true,
    length: { minimum: MIN_EMAIL_LENGTH, maximum: MAX_EMAIL_LENGTH},
    format: { with: VALID_EMAIL_REGEX, message: ": Only real email addresses, please" }

  MIN_USERNAME_LENGTH = 4
  MAX_USERNAME_LENGTH = 16 #hard-coded in database
  validates :username,
    presence: true,
    uniqueness: true,
    length: { minimum: MIN_USERNAME_LENGTH, maximum: MAX_USERNAME_LENGTH, message: ": Should be #{MIN_USERNAME_LENGTH}-#{MAX_USERNAME_LENGTH} characters"}

  MIN_NAME_LENGTH = 2
  MAX_FIRST_NAME_LENGTH = 18 #hard-coded in database
  MAX_LAST_NAME_LENGTH = 24 #hard-coded in database
  validates :first_name,
    allow_blank: true,
    length: { minimum: MIN_NAME_LENGTH, maximum: MAX_FIRST_NAME_LENGTH, message: ": Should be at least #{MIN_NAME_LENGTH} characters"}
  validates :last_name,
    allow_blank: true,
    length: { minimum: MIN_NAME_LENGTH, maximum: MAX_LAST_NAME_LENGTH, message: ": Should be at least #{MIN_NAME_LENGTH} characters"}

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def rotate_auth_token!
    generate_token(:auth_token)
    save!
  end
  def display_name
    return '[Deleted Account]' if deleted?
    if self.first_name.present?
      self.last_name.present? ? "#{self.first_name} #{self.last_name}" : self.first_name
    else
      self.username
    end
  end
  def display_first_name
    return '[Deleted Account]' if deleted?
    self.first_name.present? ? self.first_name : self.username
  end
  def full_name
    "#{self.first_name} #{self.last_name}".strip
  end
  def named_email_address
    self.full_name.blank? ? self.email : "#{self.full_name} <#{self.email}>"
  end
  def friends
    User.where(id: Friendship.where(user_id: id).select(:friend_id))
        .or(User.where(id: Friendship.where(friend_id: id).select(:user_id)))
  end
  def friends_with?(user)
    Friendship.where(user_id: id, friend_id: user.id)
              .or(Friendship.where(user_id: user.id, friend_id: id))
              .exists?
  end
  # -- Notification preferences (opt-out: empty hash = all enabled) -----------

  NOTIFICATION_TYPES = %w[friend_request friend_accepted puzzle_invite comment_on_puzzle comment_reply].freeze

  def deleted?
    deleted_at.present?
  end

  # A type is muted only if explicitly set to false. Missing key = enabled.
  def notification_muted?(type)
    notification_preferences[type.to_s] == false
  end

  # Coerce form checkbox strings ("0"/"1") to booleans for JSONB storage.
  def notification_preferences=(value)
    return super({}) if value.blank?
    return super(value) unless value.is_a?(Hash)

    coerced = value.each_with_object({}) do |(k, v), hash|
      next unless NOTIFICATION_TYPES.include?(k.to_s)
      hash[k.to_s] = ActiveModel::Type::Boolean.new.cast(v)
    end
    super(coerced)
  end

  # -- Account anonymization -------------------------------------------------

  # Strips PII but keeps the record so all FKs remain valid.
  # Uses update_columns to bypass validations (email format, password, etc).
  def anonymize!
    # Delete personal data (not community content)
    Friendship.where(user_id: id).or(Friendship.where(friend_id: id)).delete_all
    notifications.delete_all
    triggered_notifications.delete_all
    sent_friend_requests.delete_all
    received_friend_requests.delete_all
    favorite_puzzles.destroy_all
    solution_partnerings.destroy_all

    remove_image! if image.present?  # CarrierWave: deletes uploaded file

    update_columns(
      first_name: nil,
      last_name: nil,
      email: "deleted_#{id}@deleted.invalid",
      username: "deleted_#{id}",
      location: nil,
      image: nil,
      password_digest: nil,
      auth_token: nil,
      deleted_at: Time.current,
      notification_preferences: {}
    )
  end

  def self.rand_unowned_puzzle(user = nil)
    user.present? ? Crossword.unowned(user).order("RANDOM()").first : Crossword.order("RANDOM()").first
  end
end
