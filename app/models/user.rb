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
  attr_accessible :first_name, :last_name, :username, :email, :password, :password_confirmation, :crossword_ids, :comment_ids, :solution_ids, :clue_ids, :clue_instance_ids, :remote_image_url, :image

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

  def clue_count
    self.clues.count
  end
  def crossword_count
    self.crosswords.count
  end
end
