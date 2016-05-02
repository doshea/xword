# Load the Rails application.
require File.expand_path('../application', __FILE__)

class ActiveRecord::Base
  cattr_accessor :skip_callbacks

  def self.next_index
    plural = self.to_s.downcase.pluralize
    sql = "SELECT last_value from #{plural}_id_seq;"
    data = ActiveRecord::Base.connection.execute(sql)
    last_index = data.first['last_value'].to_i
    last_index + 1
  end
end

# Initialize the Rails application.
Rails.application.initialize!