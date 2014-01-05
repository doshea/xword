# == Schema Information
#
# Table name: comments
#
#  id              :integer          not null, primary key
#  content         :string(255)      not null
#  flagged         :boolean          default(FALSE), not null
#  user_id         :integer
#  crossword_id    :integer
#  base_comment_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Comment < ActiveRecord::Base
  attr_accessible :content, :flagged, :user_id, :crossword_id

  belongs_to :user, inverse_of: :comments
  belongs_to :crossword, inverse_of: :comments
  has_many :replies, class_name: 'Comment', foreign_key: 'base_comment_id', dependent: :delete_all
  belongs_to :base_comment, class_name: 'Comment'

  self.per_page = 50

end
