# frozen_string_literal: true

require 'test_helper'

class TransformerTest < Minitest::Test
  def setup
    @transformer = Klaus::Transformer.new
  end

  def test_transform_atom
    result = @transformer.apply(atom: 'hello')

    assert_instance_of Klaus::Atom, result
    assert_equal 'hello', result.value
  end

  def test_transform_string
    result = @transformer.apply(string: 'hello world')

    assert_instance_of Klaus::Atom, result
    assert_equal 'hello world', result.value
  end

  def test_transform_variable
    result = @transformer.apply(variable: 'X')

    assert_instance_of Klaus::Variable, result
    assert_equal 'X', result.name
  end

  def test_transform_anonymous_variable
    result = @transformer.apply(variable: '_')

    assert_instance_of Klaus::AnonymousVariable, result
  end

  def test_transform_zero_arity_predicate
    result = @transformer.apply(predicate: 'halt')

    assert_instance_of Klaus::Compound, result
    assert_equal 'halt', result.functor
    assert_equal [], result.arguments
    assert_equal 0, result.arity
  end

  def test_transform_single_term_predicate
    input = { predicate: 'human', terms: Klaus::Atom.new('john') }
    result = @transformer.apply(input)

    assert_instance_of Klaus::Compound, result
    assert_equal 'human', result.functor
    assert_equal 1, result.arity
    assert_equal Klaus::Atom.new('john'), result.arguments[0]
  end

  def test_transform_multi_term_predicate
    input = { predicate: 'parent', terms: [Klaus::Atom.new('john'), Klaus::Atom.new('bob')] }
    result = @transformer.apply(input)

    assert_instance_of Klaus::Compound, result
    assert_equal 'parent', result.functor
    assert_equal 2, result.arity
    assert_equal Klaus::Atom.new('john'), result.arguments[0]
    assert_equal Klaus::Atom.new('bob'), result.arguments[1]
  end

  def test_transform_fact_clause
    input = { head: Klaus::Compound.new('sunny', []) }
    result = @transformer.apply(input)

    assert_instance_of Klaus::Compound, result
    assert_equal 'sunny', result.functor
  end

  def test_transform_rule_clause
    head = Klaus::Compound.new('mortal', [Klaus::Variable.new('X')])
    body = [Klaus::Compound.new('human', [Klaus::Variable.new('X')])]
    input = { head: head, body: body }
    result = @transformer.apply(input)

    assert_instance_of Klaus::Rule, result
    assert_equal head, result.head
    assert_equal body, result.body
  end

  def test_transform_terms_sequence
    terms = [Klaus::Atom.new('a'), Klaus::Atom.new('b')]
    result = @transformer.apply(terms: terms)

    assert_equal terms, result
  end

  def test_transform_terms_single
    atom = Klaus::Atom.new('a')
    result = @transformer.apply(terms: atom)

    assert_equal [atom], result
  end
end
