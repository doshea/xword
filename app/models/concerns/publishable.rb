module Publishable
  extend ActiveSupport::Concern

  included do
    scope :standard, -> {where(rows: 15, cols: 15)}
    scope :nonstandard, -> {where.not('(rows = 15) AND (cols = 15)')}

    scope :solved, -> (user) {joins(:solutions).where(solutions: {user_id: user.id, is_complete: true}).uniq}
    scope :in_progress, -> (user) {joins(:solutions).where(solutions: {user_id: user.id, is_complete: false}).uniq}
    scope :unstarted, -> (user) {joins(:solutions).where.not(solutions: {user_id: user.id}).uniq}

    scope :solo, -> {where(solutions: {team: false})}
    scope :teamed, -> {where(solutions: {team: true})}

    scope :partnered, -> (user) {joins(:solution_partnerings).where(solution_partnerings:{user_id: user.id})}
  end



end