# frozen_string_literal: true

require 'parslet'
require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

# Klaus is an embeddable, ISO-aspirational Prolog interpreter in pure Ruby.
#
# The three module functions provide the complete public API:
# parse a knowledge base, parse a query, and solve.
module Klaus
  # Parse a Prolog knowledge base (facts and rules) into domain objects.
  #
  # @param knowledge_base_string [String] Prolog source (e.g. "parent(tom, bob).\nmortal(X) :- human(X).")
  # @return [Array<Compound, Rule>] parsed clauses
  # @raise [Parslet::ParseFailed] on malformed input
  def parse_knowledge_base(knowledge_base_string)
    parsed = KnowledgeBaseParser.new.parse(knowledge_base_string)
    Transformer.new.apply(parsed)
  end

  # Parse a Prolog query into domain objects.
  #
  # @param query_string [String] Prolog query (e.g. "parent(tom, X)")
  # @return [Compound, Array<Compound>] parsed goal(s)
  # @raise [Parslet::ParseFailed] on malformed input
  def parse_query(query_string)
    parsed = QueryParser.new.parse(query_string)
    Transformer.new.apply(parsed)
  end

  # Execute a query against a knowledge base using SLD resolution.
  #
  # @param knowledge_base [Array<Compound, Rule>] parsed knowledge base from {.parse_knowledge_base}
  # @param goals [Compound, Array<Compound>] parsed query from {.parse_query}
  # @return [Array<Environment>] solution environments with variable bindings
  def solve(knowledge_base, goals)
    unifier = Unifier.new(knowledge_base)
    unifier.solve(goals)
  end

  module_function :parse_knowledge_base, :parse_query, :solve
end
