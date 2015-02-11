# == Schema Information
#
# Table name: phrases
#
#  id         :integer          not null, primary key
#  content    :text             not null
#  created_at :datetime
#  updated_at :datetime
#

class Phrase < ActiveRecord::Base

  #TODO DECIDE HOW I WILL USE THIS MODEL IF AT ALL!!!

  has_many :clues, inverse_of: :phrase
end
