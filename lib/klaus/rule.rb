# frozen_string_literal: true

# Represents a Prolog rule (e.g., parent(X, Y) :- father(X, Y))
module Klaus
  Rule = Data.define(:head, :body) do
    def to_s
      "#{head} :- #{body.map(&:to_s).join(', ')}."
    end
  end
end
