# frozen_string_literal: true

module Klaus
  class Solver
    def initialize(knowledge_base)
      @unifier = Unifier.new(knowledge_base)
    end

    def query(goal)
      @unifier.solve(goal)
    end
  end
end
