# frozen_string_literal: true

require 'test_helper'

class ChoicePointTest < Minitest::Test
  def setup
    @env = Klaus::Environment.new
    @goal_stack = [Klaus::Compound.new('human', [Klaus::Variable.new('X')])]
    @remaining = [Klaus::Compound.new('mortal', [Klaus::Atom.new('socrates')])]
    @cp = Klaus::ChoicePoint.new(@env, @goal_stack, @remaining)
  end

  def test_env_accessor
    assert_equal @env, @cp.env
  end

  def test_goal_stack_accessor
    assert_equal @goal_stack, @cp.goal_stack
  end

  def test_remaining_clauses_accessor
    assert_equal @remaining, @cp.remaining_clauses
  end
end
