# frozen_string_literal: true

# Represents a choice point in Prolog's search tree.
#
# A choice point captures the solver state (environment, remaining goals,
# untried clauses) at a branching point, allowing the engine to backtrack
# and explore alternative proof paths.
#
# Currently defined but not wired into the solver. The engine uses
# recursive Ruby call-stack backtracking (see {Unifier}). This class
# is scaffolding for a future iterative solver that will replace the
# call stack with an explicit choice point stack, removing the depth
# limit and enabling cut/negation-as-failure.
module Klaus
  class ChoicePoint
    attr_reader :env, :goal_stack, :remaining_clauses

    def initialize(env, goal_stack, remaining_clauses)
      @env = env
      @goal_stack = goal_stack
      @remaining_clauses = remaining_clauses
    end
  end
end
