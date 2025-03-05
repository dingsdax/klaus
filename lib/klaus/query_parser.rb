# frozen_string_literal: true

# Parser for Prolog queries
# omitting ?- syntax, as we enter queries separately from knowledge base
module Klaus
  class QueryParser < PrologParser
    rule(:query) do
      predicate_with_terms >>
        (space? >> str(',') >> space? >> predicate_with_terms).repeat
    end

    root(:query)
  end
end
