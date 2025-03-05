# frozen_string_literal: true

require 'test_helper'

class UnifierTest < Minitest::Test
  def setup
    @john = Klaus::Atom.new('john')
    @bob = Klaus::Atom.new('bob')
    @lisa = Klaus::Atom.new('lisa')
    @ann = Klaus::Atom.new('ann')
    @carl = Klaus::Atom.new('carl')
    @x = Klaus::Variable.new('X')
    @y = Klaus::Variable.new('Y')
    @z = Klaus::Variable.new('Z')
  end

  def test_unify_simple_atom
    knowledge_base = [
      Klaus::Compound.new('human', [@john])
    ]
    unifier = Klaus::Unifier.new(knowledge_base)

    query = Klaus::Compound.new('human', [@john])
    solutions = unifier.solve([query])

    assert_equal 1, solutions.size
  end

  def test_unify_variable_with_atom
    knowledge_base = [
      Klaus::Compound.new('human', [@john]),
      Klaus::Compound.new('human', [@bob])
    ]
    unifier = Klaus::Unifier.new(knowledge_base)

    query = Klaus::Compound.new('human', [@x])
    solutions = unifier.solve([query])

    assert_equal 2, solutions.size
    assert_equal @john, solutions[0][:X]
    assert_equal @bob, solutions[1][:X]
  end

  def test_unify_with_rule
    knowledge_base = [
      Klaus::Compound.new('parent', [@john, @bob]),
      Klaus::Compound.new('parent', [@john, @lisa]),
      Klaus::Compound.new('parent', [@bob, @ann]),
      Klaus::Compound.new('parent', [@bob, @carl]),
      Klaus::Rule.new(
        Klaus::Compound.new('grandparent', [@x, @z]),
        [
          Klaus::Compound.new('parent', [@x, @y]),
          Klaus::Compound.new('parent', [@y, @z])
        ]
      )
    ]
    unifier = Klaus::Unifier.new(knowledge_base)

    query = Klaus::Compound.new('grandparent', [@john, @ann])
    solutions = unifier.solve([query])

    assert_equal 1, solutions.size
    assert_equal @john, solutions[0][:X]
    assert_equal @bob, solutions[0][:Y]
    assert_equal @ann, solutions[0][:Z]
  end

  def test_complex_query_with_multiple_variables
    knowledge_base = [
      Klaus::Compound.new('parent', [@john, @bob]),
      Klaus::Compound.new('parent', [@john, @lisa]),
      Klaus::Compound.new('parent', [@bob, @ann]),
      Klaus::Compound.new('parent', [@bob, @carl])
    ]
    unifier = Klaus::Unifier.new(knowledge_base)

    query = Klaus::Compound.new('parent', [@x, @y])
    solutions = unifier.solve([query])

    assert_equal 4, solutions.size

    expected_solutions = [
      { X: @john, Y: @bob },
      { X: @john, Y: @lisa },
      { X: @bob, Y: @ann },
      { X: @bob, Y: @carl }
    ]

    solutions.each_with_index do |solution, i|
      assert_equal expected_solutions[i][:X], solution[:X]
      assert_equal expected_solutions[i][:Y], solution[:Y]
    end
  end

  def test_conjunction_query
    knowledge_base = [
      Klaus::Compound.new('parent', [@john, @bob]),
      Klaus::Compound.new('parent', [@bob, @ann])
    ]
    unifier = Klaus::Unifier.new(knowledge_base)

    query1 = Klaus::Compound.new('parent', [@x, @y])
    query2 = Klaus::Compound.new('parent', [@y, @z])
    solutions = unifier.solve([query1, query2])

    assert_equal 1, solutions.size
    solution = solutions.first

    assert_equal @john, solution[:X]
    assert_equal @bob, solution[:Y]
    assert_equal @ann, solution[:Z]
  end

  def test_no_solution
    knowledge_base = [
      Klaus::Compound.new('human', [@john])
    ]
    unifier = Klaus::Unifier.new(knowledge_base)

    query = Klaus::Compound.new('human', [@bob])
    solutions = unifier.solve([query])

    assert_empty solutions
  end

  def test_anonymous_variable
    knowledge_base = [
      Klaus::Compound.new('human', [@john]),
      Klaus::Compound.new('human', [@bob])
    ]
    unifier = Klaus::Unifier.new(knowledge_base)

    anonymous_var = Klaus::AnonymousVariable.new
    query = Klaus::Compound.new('human', [anonymous_var])
    solutions = unifier.solve([query])

    assert_equal 2, solutions.size

    # Verify that the solutions don't have any bindings for the anonymous variable
    solutions.each do |solution|
      assert_empty solution.to_h
    end
  end

  def test_multiple_anonymous_variables
    knowledge_base = [
      Klaus::Compound.new('parent', [@john, @bob]),
      Klaus::Compound.new('parent', [@john, @lisa]),
      Klaus::Compound.new('parent', [@bob, @ann])
    ]
    unifier = Klaus::Unifier.new(knowledge_base)

    anonymous_var1 = Klaus::AnonymousVariable.new
    anonymous_var2 = Klaus::AnonymousVariable.new
    query = Klaus::Compound.new('parent', [anonymous_var1, anonymous_var2])
    solutions = unifier.solve([query])

    assert_equal 3, solutions.size

    # Verify that the solutions don't have any bindings for the anonymous variables
    solutions.each do |solution|
      assert_empty solution.to_h
    end
  end

  def test_multiple_parent_solutions
    knowledge_base = [
      Klaus::Compound.new('parent', [@john, @bob]),
      Klaus::Compound.new('parent', [@john, @lisa])
    ]
    unifier = Klaus::Unifier.new(knowledge_base)

    # Query for parent of X
    query = Klaus::Compound.new('parent', [@john, @x])
    solutions = unifier.solve([query])

    assert_equal 2, solutions.size

    # Verify the solutions
    expected_children = [
      Klaus::Atom.new('bob'),
      Klaus::Atom.new('lisa')
    ]

    actual_children = solutions.map { |sol| sol[:X] }

    assert_equal expected_children.to_set, actual_children.to_set
  end

  def test_query_all_parents
    knowledge_base = [
      Klaus::Compound.new('parent', [@john, @bob]),
      Klaus::Compound.new('parent', [@ann, @bob])
    ]
    unifier = Klaus::Unifier.new(knowledge_base)

    # Query for all parent relationships
    query = Klaus::Compound.new('parent', [@x, @bob])
    solutions = unifier.solve([query])

    assert_equal 2, solutions.size

    # Verify the solutions
    expected_parents = [
      [Klaus::Atom.new('john')],
      [Klaus::Atom.new('ann')]
    ]

    # Convert solutions to parent-child pairs
    actual_parents = solutions.map { |sol| [sol[:X]] }

    # Convert to sets for order-independent comparison
    assert_equal expected_parents.to_set, actual_parents.to_set
  end
end
