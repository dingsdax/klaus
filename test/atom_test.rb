# frozen_string_literal: true

require 'test_helper'

class AtomTest < Minitest::Test
  def test_value_accessor
    assert_equal 'bob', Klaus::Atom.new('bob').value
  end

  def test_to_s
    assert_equal 'bob', Klaus::Atom.new('bob').to_s
  end

  def test_equality
    assert_equal Klaus::Atom.new('bob'), Klaus::Atom.new('bob')
  end

  def test_inequality
    refute_equal Klaus::Atom.new('bob'), Klaus::Atom.new('alice')
  end

  def test_frozen
    assert_predicate Klaus::Atom.new('bob'), :frozen?
  end
end
