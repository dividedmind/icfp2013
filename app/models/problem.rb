require 'oracle'

class Problem < Sequel::Model
  unrestrict_primary_key
  
  def self.download
    problems = Oracle.myproblems
    problems.each do |problem|
      record = Problem[problem['id']] || new
      record.id = problem['id']
      record.size = problem['size']
      record.operators = problem['operators'].pg_array
      record.solved = !!problem['solved']
      record.expires_at ||= Time.now + problem['timeLeft'].seconds if problem['timeLeft']
      record.expires_at ||= 1.second.ago if problem['timeLeft'] == 0
      
      record.save
    end
    
    Problem.order_by(:size.asc)
  end
  
  def as_json *_
    super.tap do |res|
      res['timeLeft'] = [expires_at - Time.now, 0].max if expires_at
    end
  end
  
  def expired?
    expires_at < Time.now rescue false
  end
  
  def solved?
    solved
  end
end
