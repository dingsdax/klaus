# frozen_string_literal: true

require 'bundler/setup'
Bundler.require :tools

require 'simplecov'
SimpleCov.start { enable_coverage :branch }

require 'minitest/autorun'
require 'minitest/pride'

require 'klaus'

def parse_prolog_program(program)
  knowledge_base_parser = Klaus::KnowledgeBaseParser.new
  transformer = Klaus::Transformer.new

  parsed = knowledge_base_parser.parse(program)
  transformer.apply(parsed)
end

def solve_prolog_query(knowledge_base, query_string)
  query_parser = Klaus::QueryParser.new
  transformer = Klaus::Transformer.new

  parsed_query = query_parser.parse(query_string)
  transformed_query = transformer.apply(parsed_query)

  unifier = Klaus::Unifier.new(knowledge_base)

  unifier.solve([transformed_query])
end
