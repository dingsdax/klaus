# frozen_string_literal: true

module Klaus
  class Environment
    def initialize(bindings = {})
      @bindings = bindings.clone
    end

    def key?(var_name)
      @bindings.key?(var_name.to_sym)
    end

    def bind(var_name, value)
      @bindings[var_name.to_sym] = value
      true
    end

    def get_value(var_name, visited = [])
      var_key = var_name.to_sym

      # If not bound, return nil
      return nil unless key?(var_key)

      # If we've already tried to resolve this variable in this chain,
      # we've detected a cycle. In this case, return the direct binding.
      return @bindings[var_key] if visited.include?(var_key)

      # Add this variable to the visited list
      new_visited = visited + [var_key]

      # Get the bound value
      value = @bindings[var_key]

      # If it's a variable (and not an anonymous variable),
      # try to follow the reference
      if value.is_a?(Variable) && !value.is_a?(AnonymousVariable)
        next_var = value.name.to_sym

        # If we have a direct binding for this variable, try to resolve it
        if key?(next_var)
          resolved = get_value(next_var, new_visited)
          # Return the resolved value if we got one, otherwise return the original binding
          return resolved || value
        end
      end

      # For non-variables or variables without further bindings, return as is
      value
    end

    alias [] get_value
    alias []= bind

    def to_h
      result = {}

      @bindings.each_key do |var|
        # Get resolved value (avoiding cycles)
        resolved = get_value(var)
        result[var] = resolved if resolved
      end

      result
    end

    def dup
      self.class.new(@bindings.dup)
    end
  end
end
