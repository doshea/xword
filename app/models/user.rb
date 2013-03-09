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
#

class User < ActiveRecord::Base
  has_secure_password
  attr_accessible :first_name, :last_name, :username, :email, :password, :password_confirmation, :crossword_ids, :comment_ids, :solution_ids, :clue_ids, :clue_instance_ids

  has_many :crosswords, :inverse_of => :user
  has_many :comments, :inverse_of => :user
  has_many :solutions, :inverse_of => :user
  has_many :clues, :inverse_of => :user
  has_many :clue_instances, :through => :crosswords, :inverse_of => :user

end
