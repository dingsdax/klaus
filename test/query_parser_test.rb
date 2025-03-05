# frozen_string_literal: true

require 'test_helper'

class QueryParserTest < Minitest::Test
  def setup
    @parser = Klaus::QueryParser.new
  end

  def test_parse_simple_query
    result = Klaus.parse_query('human(socrates)')

    assert_kind_of Klaus::Compound, result
    assert_equal 'human', result.functor
    assert_equal 1, result.arguments.size
    assert_kind_of Klaus::Atom, result.arguments[0]
    assert_equal 'socrates', result.arguments[0].value
  end

  def test_parse_query_with_variables
    result = Klaus.parse_query('mortal(X)')

    assert_kind_of Klaus::Compound, result
    assert_equal 'mortal', result.functor
    assert_equal 1, result.arguments.size
    assert_kind_of Klaus::Variable, result.arguments[0]
    assert_equal 'X', result.arguments[0].name
  end

  def test_parse_query_with_multiple_terms
    # and whitespaces :)
    result = Klaus.parse_query('parent(john  , bob)')

    assert_kind_of Klaus::Compound, result
    assert_equal 'parent', result.functor
    assert_equal 2, result.arguments.size
    assert_kind_of Klaus::Atom, result.arguments[0]
    assert_equal 'john', result.arguments[0].value
    assert_kind_of Klaus::Atom, result.arguments[1]
    assert_equal 'bob', result.arguments[1].value
  end

  def test_parse_query_with_mixed_terms
    result = Klaus.parse_query('likes(X, chocolate)')

    assert_kind_of Klaus::Compound, result
    assert_equal 'likes', result.functor
    assert_equal 2, result.arguments.size
    assert_kind_of Klaus::Variable, result.arguments[0]
    assert_equal 'X', result.arguments[0].name
    assert_kind_of Klaus::Atom, result.arguments[1]
    assert_equal 'chocolate', result.arguments[1].value
  end

  def test_parse_query_with_anonymous_variable
    result = Klaus.parse_query('parent(_, bob)')

    assert_kind_of Klaus::Compound, result
    assert_equal 'parent', result.functor
    assert_equal 2, result.arguments.size
    assert_kind_of Klaus::AnonymousVariable, result.arguments[0]
    assert_equal :_, result.arguments[0].name
    assert_kind_of Klaus::Atom, result.arguments[1]
    assert_equal 'bob', result.arguments[1].value
  end

  def test_parse_and_transform_conjunction_query
    result = Klaus.parse_query('human(X), mortal(X)')

    assert_kind_of Array, result
    assert_kind_of Klaus::Compound, result[0]
    assert_kind_of Klaus::Compound, result[1]
    assert_equal 'human', result[0].functor
    assert_equal 'mortal', result[1].functor
    assert_equal 1, result[0].arguments.size
    assert_kind_of Klaus::Variable, result[0].arguments[0]
    assert_equal 'X', result[0].arguments[0].name
    assert_equal 1, result[1].arguments.size
    assert_kind_of Klaus::Variable, result[1].arguments[0]
    assert_equal 'X', result[1].arguments[0].name
  end

  def test_parse_complex_conjunction_query
    result = Klaus.parse_query('parent(john, X), parent(X, Y)')

    assert_kind_of Array, result
    assert_kind_of Klaus::Compound, result[0]
    assert_kind_of Klaus::Compound, result[1]
    assert_equal 'parent', result[0].functor
    assert_equal 'parent', result[1].functor
    assert_equal 2, result[0].arguments.size
    assert_kind_of Klaus::Atom, result[0].arguments[0]
    assert_equal 'john', result[0].arguments[0].value
    assert_kind_of Klaus::Variable, result[0].arguments[1]
    assert_equal 'X', result[0].arguments[1].name
    assert_equal 2, result[1].arguments.size
    assert_kind_of Klaus::Variable, result[1].arguments[0]
    assert_equal 'X', result[1].arguments[0].name
    assert_kind_of Klaus::Variable, result[1].arguments[1]
    assert_equal 'Y', result[1].arguments[1].name
  end
end
