# frozen_string_literal: true

require 'test_helper'

class CompoundTest < Minitest::Test
  def test_arity
    compound = Klaus::Compound.new('parent', [Klaus::Atom.new('tom'), Klaus::Atom.new('bob')])

    assert_equal 2, compound.arity
  end

  def test_arity_zero
    compound = Klaus::Compound.new('halt', [])

    assert_equal 0, compound.arity
  end

  def test_to_s_with_arguments
    compound = Klaus::Compound.new('parent', [Klaus::Atom.new('tom'), Klaus::Atom.new('bob')])

    assert_equal 'parent(tom, bob)', compound.to_s
  end

  def test_to_s_without_arguments
    compound = Klaus::Compound.new('halt', [])

    assert_equal 'halt', compound.to_s
  end

  def test_equality
    c1 = Klaus::Compound.new('f', [Klaus::Atom.new('a')])
    c2 = Klaus::Compound.new('f', [Klaus::Atom.new('a')])

    assert_equal c1, c2
  end

  def test_inequality_functor
    c1 = Klaus::Compound.new('f', [Klaus::Atom.new('a')])
    c2 = Klaus::Compound.new('g', [Klaus::Atom.new('a')])

    refute_equal c1, c2
  end

  def test_inequality_arguments
    c1 = Klaus::Compound.new('f', [Klaus::Atom.new('a')])
    c2 = Klaus::Compound.new('f', [Klaus::Atom.new('b')])

    refute_equal c1, c2
  end

  def test_frozen
    assert_predicate Klaus::Compound.new('f', []), :frozen?
  end
end
