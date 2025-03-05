# frozen_string_literal: true

require 'test_helper'

class VariableTest < Minitest::Test
  def test_variable_equality
    y1 = Klaus::Variable.new('Y')
    y2 = Klaus::Variable.new('Y')

    assert_equal y1, y2
  end
end
