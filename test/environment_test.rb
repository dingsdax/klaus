# frozen_string_literal: true

require 'test_helper'

class EnvironmentTest < Minitest::Test
  def setup
    @env = Klaus::Environment.new
    @atom_john = Klaus::Atom.new('john')
    @atom_bob = Klaus::Atom.new('bob')
    @var_x = Klaus::Variable.new('X')
    @var_y = Klaus::Variable.new('Y')
    @var_z = Klaus::Variable.new('Z')
  end

  def test_initialize_with_empty_bindings
    env = Klaus::Environment.new

    assert_empty env.to_h
  end

  def test_initialize_with_existing_bindings
    initial_bindings = { X: @atom_john }
    env = Klaus::Environment.new(initial_bindings)

    # env should have X bound to john
    assert_equal @atom_john, env.to_h[:X]

    # modifying the original hash shouldn't affect the environment
    initial_bindings[:Y] = @atom_bob

    refute env.key?(:Y)
  end

  def test_bind_variable
    assert @env.bind(:X, @atom_john)
    assert @env.key?(:X)
    assert_equal @atom_john, @env[:X]
  end

  def test_bind_with_bracket
    refute @env.key?(:X)

    @env[:X] = @atom_john

    assert @env.key?(:X)
    assert_equal @atom_john, @env[:X]
  end

  def test_get_value_for_unbound_variable
    assert_nil @env.get_value(:X)
  end

  def test_get_value_for_bound_atom
    @env[:X] = @atom_john

    assert_equal @atom_john, @env.get_value(:X)
  end

  def test_variable_chains
    # create a chain: X -> Y -> bob
    @env[:X] = @var_y
    @env[:Y] = @var_z
    @env[:Z] = @atom_john

    # puts "Bindings: #{@env.instance_variable_get(:@bindings)}"
    # puts "X value: #{@env[:X].inspect}"
    # puts "Y value: #{@env[:Y].inspect}"
    # puts "Z value: #{@env[:Z].inspect}"

    # get_value and [] should follow the chain
    assert_equal @atom_john, @env.get_value(:X)
    assert_equal @atom_john, @env[:X]
  end

  def test_direct_cycle_detection
    # direct cycle: X -> X
    @env[:X] = @var_x

    result = @env.get_value(:X)

    assert_equal @var_x, result
  end

  def test_simple_cycle_detection
    # simple cycle: X -> Y -> X
    @env[:X] = @var_y
    @env[:Y] = @var_x

    result = @env.get_value(:X)

    assert_equal @var_y, result
  end

  def test_complex_cycle_detection
    # create a more complex cycle: X -> Y -> Z -> X
    @env[:X] = @var_y
    @env[:Y] = @var_z
    @env[:Z] = @var_x

    result = @env.get_value(:X)

    assert_equal @var_y, result
  end

  def test_escape_from_cycle
    # Set up a situation where we initially have a cycle
    # X -> Y -> Z -> X
    @env[:X] = @var_y
    @env[:Y] = @var_z
    @env[:Z] = @var_x

    # Now break the cycle by binding Z to an atom
    @env[:Z] = @atom_john

    # Now X should resolve to john
    result = @env.get_value(:X)

    assert_equal @atom_john, result
  end

  def test_to_h_with_cycles
    # Create a cycle and make sure to_h doesn't go into infinite loop
    @env[:X] = @var_y
    @env[:Y] = @var_z
    @env[:Z] = @var_x

    # Add a normal binding too
    @env[:W] = @atom_bob

    # to_h should handle the cycle gracefully
    result = @env.to_h

    # W should be bound to bob
    assert_equal @atom_bob, result[:W]

    # The cyclic bindings should be present in some form
    assert result.key?(:X)
    assert result.key?(:Y)
    assert result.key?(:Z)
  end

  def test_compound_term_with_cycle_inside
    # Create a compound term with variable that's part of a cycle
    @env[:X] = @var_y
    @env[:Y] = @var_x

    compound = Klaus::Compound.new('father', [@var_x, @atom_bob])
    @env[:Z] = compound

    # Should get the compound with the variable that's in a cycle
    result = @env.get_value(:Z)

    assert_instance_of Klaus::Compound, result
    assert_equal 'father', result.functor
    assert_equal 2, result.arguments.length
    assert_equal @atom_bob, result.arguments[1]
  end
end
