# frozen_string_literal: true

require 'parslet'
require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

# TODO: add Sorbet for the lulz
module Klaus
  # parse a Prolog knowledge base into its internal representation
  def parse_knowledge_base(knowledge_base_string)
    parsed = KnowledgeBaseParser.new.parse(knowledge_base_string)
    Transformer.new.apply(parsed)
  end

  # parse a Prolog query into its internal representation
  def parse_query(query_string)
    parsed = QueryParser.new.parse(query_string)
    Transformer.new.apply(parsed)
  end

  # execute a query against a knowledge base
  # knowledge base & string need to be in internal representation
  def solve(knowledge_base, goals)
    unifier = Unifier.new(knowledge_base)
    unifier.solve(goals)
  end

  module_function :parse_knowledge_base, :parse_query, :solve
end
