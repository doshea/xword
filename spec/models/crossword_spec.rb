# == Schema Information
#
# Table name: crosswords
#
#  id             :integer          not null, primary key
#  title          :string(255)      default("Untitled"), not null
#  letters        :text             default(""), not null
#  description    :text
#  rows           :integer          default(15), not null
#  cols           :integer          default(15), not null
#  published      :boolean          default(FALSE), not null
#  date_published :datetime
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  circled        :boolean          default(FALSE)
#

require 'spec_helper'

describe Crossword do

end
