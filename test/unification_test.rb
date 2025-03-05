# frozen_string_literal: true

# require 'test_helper'

# class UnificationTest < Minitest::Test
#   def setup
#     @atom_john = Klaus::Atom.new("john")
#     @atom_bob = Klaus::Atom.new("bob")
#     @var_x = Klaus::Variable.new("X")
#     @var_y = Klaus::Variable.new("Y")
#     @anon_var = Klaus::AnonymousVariable.new
#   end

#   def test_unification_of_atoms
#     env = Klaus::Environment.new

#     assert @atom_john.unify(@atom_john, env)
#     refute @atom_john.unify(@atom_bob, env)

#     #should remain unchanged after atom unification
#     # atoms don't bind
#     assert_empty env.to_h
#   end

#   def test_unification_with_variables
#     env = Klaus::Environment.new

#     # variable and atom should unify
#     assert @var_x.unify(@atom_john, env)
#     assert_equal @atom_john, env[@var_x.name]

#     # 2 variables should unify
#     env = Klaus::Environment.new
#     assert @var_x.unify(@var_y, env)

#     # after X unifies with Y, X should be bound to Y
#     assert_equal @var_y, env[@var_x.name]

#     # after X = Y and Y = john, X should also be john
#     assert @var_y.unify(@atom_john, env)
#     assert_equal @atom_john, env.get_value(@var_x.name)
#   end

#   def test_unification_with_anonymous_variable
#     env = Klaus::Environment.new

#     # anonymous variable unifies with anything
#     assert @anon_var.unify(@atom_john, env)
#     assert @anon_var.unify(@var_x, env)

#     # anonymous variable doesn't create bindings
#     assert_nil env[@anon_var.name]
#   end

#   def test_unification_with_variables_in_compounds
#     parent_x_bob = Klaus::Compound.new("parent", [@var_x, @atom_bob])
#     parent_john_y = Klaus::Compound.new("parent", [@atom_john, @var_y])
#     env_1 = Klaus::Environment.new

#     # parent(X, bob) and parent(john, Y) should unify with X=john, Y=bob
#     assert parent_x_bob.unify(parent_john_y, env_1)
#     assert_equal @atom_john, env_1[@var_x.name]
#     assert_equal @atom_bob, env_1[@var_y.name]

#     parent_john_bob = Klaus::Compound.new("parent", [@atom_john, @atom_bob])
#     parent_x_y = Klaus::Compound.new("parent", [@var_x, @var_y])
#     env_2 = Klaus::Environment.new

#     # parent(X, Y) and parent(john, bob) should unify with X=john, Y=bob
#     assert parent_x_y.unify(parent_john_bob, env_2)
#     assert_equal @atom_john, env_2[@var_x.name]
#     assert_equal @atom_bob, env_2[@var_y.name]
#   end
# end
