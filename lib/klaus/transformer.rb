# frozen_string_literal: true

# Transform Parslet output into Klause' Prolog domain objects
module Klaus
  class Transformer < Parslet::Transform
    rule(atom: simple(:atom)) { Atom.new(atom) }
    rule(string: simple(:string)) { Atom.new(string) }
    rule(variable: simple(:variable)) do
      var_name = String(variable)
      var_name == '_' ? AnonymousVariable.new : Variable.new(var_name)
    end

    rule(terms: sequence(:terms)) { terms }
    rule(terms: simple(:term)) { [term] }

    rule(predicate: simple(:predicate)) do
      Compound.new(predicate)
    end

    rule(predicate: simple(:predicate), terms: simple(:term)) do
      Compound.new(predicate, [term])
    end

    rule(predicate: simple(:predicate), terms: sequence(:terms)) do
      Compound.new(predicate, terms)
    end

    rule(head: subtree(:head)) do
      head
    end

    rule(head: subtree(:head), body: subtree(:body)) do
      Rule.new(head, body)
    end
  end
end
