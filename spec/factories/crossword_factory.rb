# == Schema Information
#
# Table name: crosswords
#
#  id             :integer          not null, primary key
#  title          :string(255)      default("Untitled"), not null
#  published      :boolean          default(FALSE)
#  date_published :datetime
#  description    :text
#  rows           :integer          default(15), not null
#  cols           :integer          default(15), not null
#  letters        :text             default(""), not null
#  circles        :text
#  across_nums    :text             default(""), not null
#  down_nums      :text             default(""), not null
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
end
