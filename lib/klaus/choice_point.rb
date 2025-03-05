# frozen_string_literal: true

# Represents a choice point for backtracking
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
