# frozen_string_literal: true

# Represents a Prolog atom (constant, e.g., 'bob')
module Klaus
  Atom = Data.define(:value) do
    def to_s
      value.to_s
    end
  end
end
