# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  first_name      :string(255)
#  last_name       :string(255)
#  username        :string(255)      not null
#  email           :string(255)      not null
#  is_admin        :boolean          default(FALSE)
#  password_digest :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  image           :text
#  location        :string(255)
#

class User < ActiveRecord::Base
  has_secure_password
  attr_accessible :first_name, :last_name, :username, :email, :password, :password_confirmation, :crossword_ids, :comment_ids, :solution_ids, :clue_ids, :clue_instance_ids, :remote_image_url, :image, :location

  include PgSearch
  pg_search_scope :starts_with,
                  :against => [:first_name, :last_name, :username],
                  :using => {
                    :tsearch => {:prefix => true}
                  }

  mount_uploader :image, AccountPicUploader

  has_many :crosswords, :inverse_of => :user
  has_many :comments, :inverse_of => :user
  has_many :solutions, :inverse_of => :user
  has_many :clues, :inverse_of => :user
  has_many :clue_instances, :through => :crosswords, :inverse_of => :user

  MIN_PASSWORD_LENGTH = 5
  MAX_PASSWORD_LENGTH = 16
  validates :password,
    :presence => true,
    :confirmation => true,
    :length => { :minimum => MIN_PASSWORD_LENGTH, :maximum => MAX_PASSWORD_LENGTH, :message => ": Should be #{MIN_PASSWORD_LENGTH}-#{MAX_PASSWORD_LENGTH} characters" }

  MAX_EMAIL_LENGTH = 25
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email,
    :presence => true,
    :uniqueness => true,
    :length => { :maximum => MAX_EMAIL_LENGTH, :message => ": That's just too long. Your email shouldn't be above #{MAX_EMAIL_LENGTH} characters" },
    :format => { with: VALID_EMAIL_REGEX, :message => ": Only real email addresses, please" }

  MAX_USERNAME_LENGTH = 12
  MIN_USERNAME_LENGTH = 4
  validates :username,
    :presence => true,
    :uniqueness => true,
    :length => { :minimum => MIN_USERNAME_LENGTH, :maximum => MAX_USERNAME_LENGTH, :message => ": Should be #{MIN_USERNAME_LENGTH}-#{MAX_USERNAME_LENGTH} characters"}

  MIN_NAME_LENGTH = 2
  validates :first_name,
    :presence => true,
    :length => { :minimum => MIN_NAME_LENGTH, :message => ": Should be at least #{MIN_NAME_LENGTH} characters"}
  validates :last_name,
    :presence => true,
    :length => { :minimum => MIN_NAME_LENGTH, :message => ": Should be at least #{MIN_NAME_LENGTH} characters"}

  def clue_count
    self.clues.count
  end
  def crossword_count
    self.crosswords.count
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
  def rand_unowned_puzzle
    Crossword.where('user_id != ?', self.id).order("RANDOM()").first
  end
end
