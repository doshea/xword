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
    scope :all_in_progress, -> (user) { unowned(user).in_progress(user).union(partnered_in_progress(user)).distinct }
    scope :all_solved,      -> (user) { unowned(user).solved(user).union(partnered_solved(user)).distinct }

    scope :started,   -> (user) { with_solution(user).union(partnered(user)) }

    # Pluck once and guard against empty IN() — the [0] sentinel was fragile and ran pluck twice.
    scope :unstarted, -> (user) {
      started_ids = started(user).pluck(:id)
      base = unowned(user).distinct
      started_ids.any? ? base.where.not(id: started_ids) : base
    }

    scope :new_to_user, -> (user) {
      partnered_ids = partnered(user).pluck(:id)
      base = unowned(user).unstarted(user).distinct
      partnered_ids.any? ? base.where.not(id: partnered_ids) : base
    }
  end



end