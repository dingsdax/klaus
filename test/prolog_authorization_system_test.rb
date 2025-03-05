# frozen_string_literal: true

class PrologIntegrationTest < Minitest::Test
  def setup
    # Create atoms for users, roles, and actions
    @franzi = Klaus::Atom.new('franzi')
    @susi = Klaus::Atom.new('susi')
    @editor = Klaus::Atom.new('editor')
    @viewer = Klaus::Atom.new('viewer')
    @edit = Klaus::Atom.new('edit')
    @view = Klaus::Atom.new('view')

    # Prepare the knowledge base with facts and rules
    @knowledge_base = [
      # Role facts
      Klaus::Compound.new('role', [@franzi, @editor]),
      Klaus::Compound.new('role', [@susi, @viewer]),

      # Permission facts
      Klaus::Compound.new('permission', [@editor, @edit]),
      Klaus::Compound.new('permission', [@editor, @view]),
      Klaus::Compound.new('permission', [@viewer, @view]),

      # Rule for can_access
      Klaus::Rule.new(
        Klaus::Compound.new('can_access', [
                              Klaus::Variable.new('User'),
                              Klaus::Variable.new('Action')
                            ]),
        [
          Klaus::Compound.new('role', [
                                Klaus::Variable.new('User'),
                                Klaus::Variable.new('Role')
                              ]),
          Klaus::Compound.new('permission', [
                                Klaus::Variable.new('Role'),
                                Klaus::Variable.new('Action')
                              ])
        ]
      )
    ]

    # Create the unifier
    @unifier = Klaus::Unifier.new(@knowledge_base)
  end

  def test_franzi_can_edit
    query = Klaus::Compound.new('can_access', [@franzi, @edit])
    solutions = @unifier.solve([query])

    assert_equal 1, solutions.size
    assert_equal @franzi, solutions.first[:User]
    assert_equal @edit, solutions.first[:Action]
  end

  def test_susi_cannot_edit
    query = Klaus::Compound.new('can_access', [@susi, @edit])
    solutions = @unifier.solve([query])

    assert_empty solutions
  end

  def test_who_can_view
    query = Klaus::Compound.new('can_access', [
                                  Klaus::Variable.new('User'),
                                  @view
                                ])
    solutions = @unifier.solve([query])

    assert_equal 2, solutions.size

    # Collect the users who can view
    view_users = solutions.map { |sol| sol[:User] }

    # Assert that both Franzi and Susi can view
    assert_includes view_users, @franzi
    assert_includes view_users, @susi
  end

  def test_role_and_permission_queries
    # Query roles
    role_query = Klaus::Compound.new('role', [
                                       Klaus::Variable.new('User'),
                                       Klaus::Variable.new('Role')
                                     ])
    role_solutions = @unifier.solve([role_query])

    assert_equal 2, role_solutions.size

    # Collect roles
    roles = role_solutions.map { |sol| [sol[:User], sol[:Role]] }

    assert_includes roles, [@franzi, @editor]
    assert_includes roles, [@susi, @viewer]
  end
end
