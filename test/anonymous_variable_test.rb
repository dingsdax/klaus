# frozen_string_literal: true

require 'test_helper'

class AnonymousVariableTest < Minitest::Test
  def test_name_returns_underscore_symbol
    assert_equal :_, Klaus::AnonymousVariable.new.name
  end

  def test_to_s_returns_underscore
    assert_equal '_', Klaus::AnonymousVariable.new.to_s
  end

  def test_all_instances_are_equal
    assert_equal Klaus::AnonymousVariable.new, Klaus::AnonymousVariable.new
  end

  def test_not_a_variable
    refute_kind_of Klaus::Variable, Klaus::AnonymousVariable.new
  end

  def test_is_data
    assert_kind_of Data, Klaus::AnonymousVariable.new
  end
end
