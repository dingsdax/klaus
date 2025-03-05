# frozen_string_literal: true

# Base parser for Prolog syntax
module Klaus
  class PrologParser < Parslet::Parser
    # Common elements
    rule(:space) { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
    rule(:eof) { any.absent? }

    rule(:atom) { match['a-z'] >> match['a-zA-Z_0-9'].repeat }
    rule(:variable) { match['A-Z_'] >> match['a-zA-Z_0-9'].repeat }
    rule(:string) { str('"') >> match['^\\"'].repeat.as(:string) >> str('"') }
    rule(:term) { atom.as(:atom) | variable.as(:variable) | string }

    # Terms and predicates
    rule(:term_list) { term >> (space? >> str(',') >> space? >> term).repeat }
    rule(:term_sequence) { str('(') >> space? >> term_list.maybe.as(:terms) >> space? >> str(')') }
    rule(:predicate_with_terms) { atom.as(:predicate) >> space? >> term_sequence.maybe }

    # Clause: Fact or Rule
    rule(:clause) do
      predicate_with_terms.as(:head) >>
        (space? >> str(':-') >> space? >> body.as(:body)).maybe >>
        space? >> str('.')
    end
    rule(:body) { predicate_with_terms >> (str(',') >> space? >> predicate_with_terms).repeat(0) } # conjunction
  end
end
