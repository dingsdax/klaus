# frozen_string_literal: true

# Parser for Prolog facts & rules
module Klaus
  class KnowledgeBaseParser < PrologParser
    rule(:program) { (clause >> space?).repeat(1) }
    root(:program)
  end
end
