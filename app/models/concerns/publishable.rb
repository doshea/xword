module Publishable
  extend ActiveSupport::Concern

  included do
    scope :with_solution, -> (user) {joins(:solutions).where(solutions: {user_id: user.id})}
    scope :solved, -> (user) { with_solution(user).merge(Solution.complete)}
    scope :in_progress, -> (user) {with_solution(user).merge(Solution.incomplete)}

    scope :partnered, -> (user) {joins(:solution_partnerings).where(solution_partnerings:{user_id: user.id})}
    scope :partnered_solved, -> (user) {partnered(user).merge(Solution.complete)}
    scope :partnered_in_progress, -> (user) {partnered(user).merge(Solution.incomplete)}

    scope :all_in_progress, -> (user) { unowned(user).in_progress(user).union(partnered_in_progress(user)).distinct }
    scope :all_solved,      -> (user) { unowned(user).solved(user).union(partnered_solved(user)).distinct }

    scope :started,   -> (user) { with_solution(user).union(partnered(user)) }

    # Subquery-based: avoids materializing IDs into Ruby arrays.
    scope :unstarted, -> (user) {
      unowned(user).where.not(id: started(user).select(:id)).distinct
    }

    scope :new_to_user, -> (user) {
      unowned(user).unstarted(user).where.not(id: partnered(user).select(:id)).distinct
    }
  end



end