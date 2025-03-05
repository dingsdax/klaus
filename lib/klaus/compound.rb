# frozen_string_literal: true

# Represents a Prolog compound term (e.g., father(john, bob))
# A compound is any term that has a functor (name) and arguments:
# * a standalone fact in the knowledge base
# * a head of a rule
# * a goal in a query
# * a subgoal in a rule body
module Klaus
  Compound = Data.define(:functor, :arguments) do
    def arity
      arguments.length
    end

    def to_s
      if arguments.empty?
        functor
      else
        "#{functor}(#{arguments.map(&:to_s).join(', ')})"
      end
    end
  end
end
