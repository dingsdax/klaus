# frozen_string_literal: true

require 'test_helper'

class RuleTest < Minitest::Test
  def setup
    @head = Klaus::Compound.new('mortal', [Klaus::Variable.new('X')])
    @body = [Klaus::Compound.new('human', [Klaus::Variable.new('X')])]
    @rule = Klaus::Rule.new(@head, @body)
  end

  def test_head_accessor
    assert_equal @head, @rule.head
  end

  def test_body_accessor
    assert_equal @body, @rule.body
  end

  def test_to_s
    assert_equal 'mortal(X) :- human(X).', @rule.to_s
  end

  def test_equality
    other = Klaus::Rule.new(@head, @body)

    assert_equal @rule, other
  end

  def test_frozen
    assert_predicate @rule, :frozen?
  end
end
