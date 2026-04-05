# frozen_string_literal: true

require 'test_helper'

class VariableTest < Minitest::Test
  def test_variable_equality
    y1 = Klaus::Variable.new('Y')
    y2 = Klaus::Variable.new('Y')

    assert_equal y1, y2
  end

  def test_variable_inequality
    x = Klaus::Variable.new('X')
    y = Klaus::Variable.new('Y')

    refute_equal x, y
  end

  def test_to_s
    assert_equal 'X', Klaus::Variable.new('X').to_s
  end

  def test_name_accessor
    assert_equal 'X', Klaus::Variable.new('X').name
  end

  def test_not_anonymous
    refute_kind_of Klaus::AnonymousVariable, Klaus::Variable.new('X')
  end

  def test_frozen
    assert_predicate Klaus::Variable.new('X'), :frozen?
  end
end
