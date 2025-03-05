# frozen_string_literal: true

require 'test_helper'

class KnowledgeBaseParserTest < Minitest::Test
  def test_parsing_and_transforming_a_single_fact
    result = Klaus.parse_knowledge_base('human(socrates).')

    assert_equal 1, result.size
    assert_equal 'human', result[0].functor
    assert_equal 1, result[0].arguments.size
    assert_equal 'socrates', result[0].arguments[0].value
  end

  def test_parsing_and_transforming_multiple_facts
    result = Klaus.parse_knowledge_base('human(socrates). mortal(socrates).')

    assert_equal 2, result.size
    assert_equal 'human', result[0].functor
    assert_equal 'mortal', result[1].functor
    assert_equal 1, result[0].arguments.size
    assert_equal 1, result[1].arguments.size
    assert_equal 'socrates', result[0].arguments[0].value
    assert_equal 'socrates', result[1].arguments[0].value
  end

  def test_parsing_and_transforming_a_single_rule
    result = Klaus.parse_knowledge_base('mortal(X) :- human(X).')

    assert_equal 1, result.size
    assert_kind_of Klaus::Rule, result[0]

    rule = result[0]

    assert_kind_of Klaus::Compound, rule.head
    assert_kind_of Klaus::Compound, rule.body
    assert_equal 'mortal', rule.head.functor
    assert_equal 'human', rule.body.functor
    assert_equal 1, rule.head.arguments.size
    assert_equal 1, rule.body.arguments.size
    assert_kind_of Klaus::Variable, rule.head.arguments[0]
    assert_kind_of Klaus::Variable, rule.body.arguments[0]
    assert_equal 'X', rule.head.arguments[0].name
    assert_equal 'X', rule.body.arguments[0].name
  end

  def test_family_relationship_knowledge_base
    program = <<~PROLOG
      parent(john, bob).
      parent(john, lisa).
      parent(bob, ann).
      parent(bob, carl).

      grandparent(X, Z) :- parent(X, Y), parent(Y, Z).
    PROLOG

    result = Klaus.parse_knowledge_base(program)
    # TODO: sibling(X, Y) :- parent(P, X), parent(P, Y), X \\= Y.

    assert_equal 5, result.size
    assert_equal ['parent'], result[0..3].map { |compound| compound.functor.to_s }.uniq
    assert_equal %w[john bob], result[0].arguments.map(&:value)
    assert_equal %w[john lisa], result[1].arguments.map(&:value)
    assert_equal %w[bob ann], result[2].arguments.map(&:value)
    assert_equal %w[bob carl], result[3].arguments.map(&:value)

    rule = result[4]

    assert_equal 'grandparent', rule.head.functor
    assert_equal 2, rule.body.size
    assert_equal(%w[parent parent], rule.body.map(&:functor))
    assert_equal(%w[X Y], rule.body[0].arguments.map(&:name))
    assert_equal(%w[Y Z], rule.body[1].arguments.map(&:name))
  end
end
