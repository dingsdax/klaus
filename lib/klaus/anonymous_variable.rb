# frozen_string_literal: true

# Anonymous variable (represented by '_' in Prolog)
# used when you need a variable in a term or pattern
# but we don't care about its value and won't be referencing it
module Klaus
  AnonymousVariable = Data.define do
    def name
      :_
    end

    def to_s
      '_'
    end
  end
end
