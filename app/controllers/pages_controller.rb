class PagesController < ApplicationController

  layout 'logged_out_home', :only => [:home]

  def home
  end
  def unauthorized
  end
  def account_required
  end
end