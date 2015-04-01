module ApplicationHelper

  def is_admin?
    @current_user.present? && @current_user.is_admin
  end

  def is_logged_in?
    @current_user.present?
  end

  def random_char
    (65+rand(26) + rand(2)*32).chr
  end

  def title(s, override=false)
    content_for(:title){override ? s : "#{s} | Crossword Café"}
  end

  def title_backup
    if content_for? :title
      return nil
    else
      'Crossword Café'
    end
  end

end