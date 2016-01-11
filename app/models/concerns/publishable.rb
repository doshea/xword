module Publishable
  extend ActiveSupport::Concern

  included do
    scope :standard, -> {where(rows: 15, cols: 15)}
    scope :nonstandard, -> {where.not('(rows = 15) AND (cols = 15)')}

    scope :with_solution, -> (user) {joins(:solutions).where(solutions: {user_id: user.id})}
    scope :solved, -> (user) { with_solution(user).merge(Solution.complete)}
    scope :in_progress, -> (user) {with_solution(user).merge(Solution.incomplete)}

    scope :solo, -> {where(solutions: {team: false})}
    scope :teamed, -> {where(solutions: {team: true})}

    scope :partnered, -> (user) {joins(:solution_partnerings).where(solution_partnerings:{user_id: user.id})}
    scope :partnered_solved, -> (user) {partnered(user).merge(Solution.complete)}
    scope :partnered_in_progress, -> (user) {partnered(user).merge(Solution.incomplete)}

    # Actually used by the home page
    scope :all_in_progress, -> (user){ unowned(user).in_progress(user).union(partnered_in_progress(user)).uniq }
    scope :all_solved, -> (user){ unowned(user).solved(user).union(partnered_solved(user)).uniq }
    scope :new_to_user, -> (user){ unowned(user).unstarted(user).where.not("crosswords.id IN (?)", (partnered(user).pluck(:id).blank? ? [0] : partnered(user).pluck(:id))).uniq }
  
    scope :started, -> (user){ with_solution(user).union(partnered(user))}
    scope :unstarted, -> (user){ unowned(user).where.not("crosswords.id IN (?)", (started(user).pluck(:id).blank? ? [0] : started(user).pluck(:id))).uniq}
  end



end