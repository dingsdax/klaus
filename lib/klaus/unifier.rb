# frozen_string_literal: true

module Klaus
  class Unifier
    def initialize(knowledge_base)
      @knowledge_base = knowledge_base
    end

    def solve(queries, env = Environment.new)
      # Special case for queries with only anonymous variables
      return solve_anonymous_variables(queries) if queries.all? { |query| query.arguments.all?(AnonymousVariable) }

      # Track all unique solutions
      solutions = []
      solution_set = Set.new

      # Try all clauses for each query
      solve_recursive(queries, env, solutions, solution_set)

      solutions
    end

    private

    def solve_anonymous_variables(queries)
      # Find matching facts for each query
      solutions = []

      queries.each do |query|
        query_matches = @knowledge_base.select do |clause|
          clause.is_a?(Compound) &&
            clause.functor == query.functor &&
            # TODO: use arity
            clause.arguments.length == query.arguments.length
        end

        solutions = if solutions.empty?
                      # First query, initialize solutions
                      query_matches.map { |_| Environment.new }
                    else
                      # Ensure consistent number of solutions
                      solutions * query_matches.size
                    end
      end

      solutions
    end

    def solve_recursive(queries, env, solutions, solution_set, depth = 0)
      # Prevent infinite recursion
      return if depth > 100

      # If no queries left, we've found a solution
      if queries.empty?
        # Create a solution hash that excludes any anonymous variable bindings
        solution_hash = env.to_h.reject { |_, value| value.is_a?(AnonymousVariable) }

        unless solution_set.include?(solution_hash)
          solutions << env
          solution_set << solution_hash
        end
        return
      end

      current_query = queries.first
      remaining_queries = queries[1..] || []

      # Try to match current query with each knowledge base clause
      @knowledge_base.each do |clause|
        # Try to unify the current query with the clause
        new_envs = try_unify(current_query, clause, env)

        # If unification succeeds, recursively solve remaining queries
        new_envs.each do |new_env|
          solve_recursive(remaining_queries, new_env, solutions, solution_set, depth + 1)
        end
      end
    end

    def try_unify(query, clause, env)
      case clause
      when Compound
        # For a simple fact, try direct unification
        unify_result = unify(query, clause, env.dup)
        unify_result ? [unify_result] : []
      when Rule
        # For a rule, unify the head and then try to satisfy body
        unify_results = []
        if (unified_env = unify(query, clause.head, env.dup))
          # If head unifies, try to solve the rule's body
          body_solutions = solve(clause.body, unified_env)
          unify_results.concat(body_solutions)
        end
        unify_results
      else
        []
      end
    end

    def unify(term1, term2, env)
      # If both are anonymous variables, always match
      return env if term1.is_a?(AnonymousVariable) && term2.is_a?(AnonymousVariable)

      # Resolve any variables through the environment
      term1 = resolve(term1, env)
      term2 = resolve(term2, env)

      # If both are the same, return the environment
      return env if term1 == term2

      # Anonymous variables always match without binding
      return env if term1.is_a?(AnonymousVariable) || term2.is_a?(AnonymousVariable)

      # If term1 is a variable (but not anonymous)
      if term1.is_a?(Variable)
        # Bind the variable if it's not already bound
        return env.bind(term1.name, term2) ? env : nil
      end

      # If term2 is a variable (but not anonymous)
      if term2.is_a?(Variable)
        # Bind the variable if it's not already bound
        return env.bind(term2.name, term1) ? env : nil
      end

      # If both are compounds with the same functor and arity
      if term1.is_a?(Compound) && term2.is_a?(Compound) &&
         term1.functor == term2.functor &&
         term1.arguments.length == term2.arguments.length
        # Unify each argument recursively
        term1.arguments.zip(term2.arguments).each do |arg1, arg2|
          env = unify(arg1, arg2, env)
          return nil unless env
        end
        return env
      end

      # Unification fails
      nil
    end

    def resolve(term, env)
      # If term is a variable (but not anonymous)
      if term.is_a?(Variable) && !term.is_a?(AnonymousVariable)
        # Try to resolve its value in the environment
        resolved = env.get_value(term.name)
        resolved || term
      else
        term
      end
    end
  end
end
