require 'oracle'

class Problem < Sequel::Model
  def self.download
    problems = Oracle.myproblems
    problems.each do |problem|
      record = Problem[problem['id']] || new
      record.id = problem['id']
      record.size = problem['size']
      record.operators = problem['operators'].pg_array
      record.solved = !!problem['solved']
      record.expires_at = Time.now + problem['timeLeft'].seconds if problem['timeLeft']
      
      record.save
    end
    
    Problem.order_by(:size.asc)
  end
end
