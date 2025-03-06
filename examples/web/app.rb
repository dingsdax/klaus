# frozen_string_literal: true

require 'roda'
require 'klaus'
require 'tilt/erubi'
require 'json'

class KlausTerminal < Roda
  plugin :render, engine: 'erb', views: 'app/views'
  plugin :json

  route do |r|
    # Root route - display the main interface
    r.root do
      @knowledge_base = "human(socrates).\nmortal(X) :- human(X)."
      @query = "mortal(socrates)."
      @result = ""
      
      view('index')
    end
    
    # Solve route - process the query and return results as JSON
    r.on "solve" do
      r.post do
        knowledge_base_text = r.params['knowledge_base'].to_s
        query_text = r.params['query'].to_s
          
        kb = Klaus.parse_knowledge_base(knowledge_base_text)
        query = Klaus.parse_query(query_text)
          
        query_array = query.is_a?(Array) ? query : [query]
          
        solutions = Klaus.solve(kb, query_array)
          
        if solutions.empty?
          result = "No solutions found."
        else
          result = "Solutions found (#{solutions.size}):\n"
            
          solutions.each_with_index do |solution, index|
            result << "\nSolution #{index + 1}:\n"
              
            if solution.to_h.empty?
              result << "  true.\n"
            else
              solution.to_h.each do |var, value|
                result << "  #{var} = #{value}\n"
              end
            end
          end          

          { success: true, result: result }
        end
      end
    end
  end
end