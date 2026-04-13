# frozen_string_literal: true

require 'test_helper'

class IntegrationTest < Minitest::Test
  def test_authentication_system
    program = <<~PROLOG
      role(franzi, editor).
      role(susi, viewer).

      permission(editor, edit).
      permission(editor, view).
      permission(viewer, view).

      can_access(User, Action) :- role(User, Role), permission(Role, Action).
    PROLOG

    knowledge_base = parse_prolog_program(program)

    queries = [
      'can_access(franzi, edit)',
      'can_access(susi, edit)',
      'can_access(User, view)'
    ]

    expected_results = [
      # Franzi can edit
      1,
      # Susi cannot edit
      0,
      # Users who can view
      2
    ]

    queries.zip(expected_results).each do |query_string, expected_count|
      solutions = solve_prolog_query(knowledge_base, query_string)

      assert_equal expected_count, solutions.size, "Failed query: #{query_string}"
    end

    # Detailed check for who can view
    view_query_solutions = solve_prolog_query(knowledge_base, 'can_access(User, view)')
    view_users = view_query_solutions.map { |sol| sol[:User] }

    assert_includes view_users, Klaus::Atom.new('franzi')
    assert_includes view_users, Klaus::Atom.new('susi')
  end

  def test_family_relationships
    program = <<~PROLOG
      parent(john, bob).
      parent(john, lisa).
      parent(bob, ann).
      parent(bob, carl).

      grandparent(X, Z) :- parent(X, Y), parent(Y, Z).
    PROLOG

    # Parse the knowledge base
    knowledge_base = parse_prolog_program(program)

    # Test queries
    queries = [
      'parent(john, bob)',
      'parent(bob, ann)',
      'grandparent(john, ann)'
    ]

    expected_results = [
      # Direct parents
      1,
      # Bob's child
      1,
      # Grandparent relationship
      1
    ]

    queries.zip(expected_results).each do |query_str, expected_count|
      solutions = solve_prolog_query(knowledge_base, query_str)

      assert_equal expected_count, solutions.size, "Failed query: #{query_str}"
    end

    # Check all grandparent relationships
    grandparent_solutions = solve_prolog_query(knowledge_base, 'grandparent(X, Z)')

    assert_equal 2, grandparent_solutions.size

    solution = grandparent_solutions[0]

    assert_equal Klaus::Atom.new('john'), solution[:X]
    assert_equal Klaus::Atom.new('ann'), solution[:Z]

    solution = grandparent_solutions[1]

    assert_equal Klaus::Atom.new('john'), solution[:X]
    assert_equal Klaus::Atom.new('carl'), solution[:Z]
  end

  def test_zero_arity_facts
    program = <<~PROLOG
      halt.
      sunny.
      raining.
    PROLOG

    knowledge_base = parse_prolog_program(program)

    assert_equal 3, knowledge_base.size

    knowledge_base.each do |fact|
      assert_instance_of Klaus::Compound, fact
      assert_equal 0, fact.arity
      assert_equal [], fact.arguments
    end

    assert_equal 'halt', knowledge_base[0].functor
    assert_equal 'sunny', knowledge_base[1].functor

    # Query a zero-arity fact
    solutions = solve_prolog_query(knowledge_base, 'halt')

    assert_equal 1, solutions.size

    # Query a non-existent zero-arity fact
    solutions = solve_prolog_query(knowledge_base, 'missing')

    assert_equal 0, solutions.size
  end

  def test_zero_arity_facts_in_rules
    program = <<~PROLOG
      sunny.
      warm.
      go_outside :- sunny, warm.
    PROLOG

    knowledge_base = parse_prolog_program(program)
    solutions = solve_prolog_query(knowledge_base, 'go_outside')

    assert_equal 1, solutions.size
  end
end
