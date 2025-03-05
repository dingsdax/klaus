# frozen_string_literal: true

# Represents a Prolog variable (e.g., X, Y, Z)
module Klaus
  Variable = Data.define(:name) do
    def to_s
      name.to_s
    end
  end
end
