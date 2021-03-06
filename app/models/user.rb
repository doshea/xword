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

class User < ActiveRecord::Base
  has_secure_password

  has_many :crosswords, inverse_of: :user
  has_many :unpublished_crosswords, inverse_of: :user
  has_many :comments, inverse_of: :user
  has_many :solutions, inverse_of: :user
  has_many :clues, inverse_of: :user

  has_many :favorite_puzzles, inverse_of: :user
  has_many :favorites, through: :favorite_puzzles, source: :crossword

  has_many :solution_partnerings, inverse_of: :user, dependent: :destroy
  has_many :team_solutions, through: :solution_partnerings, source: :user

  #Weird workaround to generate bidirectional HABTM with same model
  has_many :friendship_ones, :class_name => 'Friendship', :foreign_key => :friend_id
  has_many :friend_ones, class_name: 'User', through: :friendship_ones
  has_many :friendship_twos, :class_name => 'Friendship', :foreign_key => :user_id
  has_many :friend_twos, class_name: 'User', through: :friendship_twos

  before_create { generate_token(:auth_token); generate_token(:verification_token); }

  include PgSearch
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
    end while User.exists?(column => self[column]) #may need a colon
  end
  def display_name
    if self.first_name.present?
      self.last_name.present? ? "#{self.first_name} #{self.last_name}" : self.first_name
    else
      self.username
    end
  end
  def display_first_name
    self.first_name.present? ? self.first_name : self.username
  end
  def full_name
    "#{self.first_name} #{self.last_name}".strip
  end
  def named_email_address
    self.full_name.blank? ? self.email : "#{self.full_name} <#{self.email}>"
  end
  def friends
    friend_ones + friend_twos
  end
  def friends_with?(user)
    friends.include?(user)
  end
  def self.rand_unowned_puzzle
    @current_user.present? ? Crossword.unowned(@current_user).order("RANDOM()").first : Crossword.order("RANDOM()").first
  end
end
