module Publishable
  extend ActiveSupport::Concern

  included do
    default_scope {order(published_at: :desc)}
    scope :published, -> {where(published: true)}
    scope :unpublished, -> {where(published: false)}

    scope :standard, -> {where(rows: 15, cols: 15)}
    scope :nonstandard, -> {where.not('(rows = 15) AND (cols = 15)')}

    scope :solved, -> (user_id) {joins(:solutions).where(solutions: {user_id: user_id, is_complete: true}).published.distinct}
    scope :in_progress, -> (user_id) {joins(:solutions).where(solutions: {user_id: user_id, is_complete: false}).distinct}
    scope :unstarted, -> (user_id) {joins(:solutions).where.not(solutions: {user_id: user_id}).published.distinct}

    scope :solo, -> {where(solutions: {team: false})}
    scope :teamed, -> {where(solutions: {team: true})}

    scope :partnered, -> (user_id) {joins(:solution_partnerings).where(solution_partnerings:{user_id: user_id})}


  end



end