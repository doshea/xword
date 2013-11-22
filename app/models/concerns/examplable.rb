module Examplable
  extend ActiveSupport::Concern

  included do
    #attr_accessible
    #scopes
    #has_many and belongs_to
  end

  def instance_example
    #instance method
  end

  module ClassMethods
    def class_example #notice that there is no "self." in this method name! It is not necessary when using ActiveSupport::Concern!
    end
  end

end