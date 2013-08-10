#!/usr/bin/env ruby
require 'json'
require 'rest-client'
$: << '.'
require 'bv'

size = 10
operators = []
problems = JSON.parse RestClient.get('http://icfp2013lf.herokuapp.com/myproblems?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', nil)
#problems = [JSON.parse(RestClient.post('http://icfp2013lf.herokuapp.com/train?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', {size: 42}.to_json))]
problems = problems.find_all {|a| a['size'] <= size && (!a['solved']) && (a['timeLeft'] || 42) > 0}
#problems = [{"id"=>"3OVf2IsEAbkuaqElXg7Ax3je", "size"=>5, "operators"=>["or", "shl1"], "solved"=>false, "expires_at"=>nil, "solution"=>nil, "kind"=>"contest"}]
#problems = [{"id"=>"2fx0Sizj7aDOX8cXKnqI1Adw", "size"=>8, "operators"=>["and", "not", "plus", "shr1"], "solved"=>false, "expires_at"=>nil, "solution"=>nil, "kind"=>"contest"}]
problems.each do |problem|
begin
  ops = problem['operators']
  next unless operators.all?{|x| ops.include? ops}
  p problem
  solutions = BV.generate size: problem['size'], operators: ops
  puts "%d solutions total." % solutions.length
  next if solutions.length > 100000
  reqs = 0
  start_time = Time.now
  while solutions.length > 0
    puts "%d solutions left." % solutions.length
    sol = solutions.shuffle.first
    program = sol.to_s
    puts program
    reqs += 1
    result = JSON.parse(RestClient.post('http://icfp2013lf.herokuapp.com/guess?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', {id: problem["id"], program: program}.to_json))
    p result
    case result['status']
    when 'win'
      break
    when 'mismatch'
      solutions.reject! {|s| s.eval(Integer(result['values'][0])) != Integer(result['values'][1])}
    else
      raise "unknown response: #{result}"
    end
    raise "couldn't solve!!" if solutions.length < 1
  end
  puts "Solved in %d requests (%s s).\n" % [reqs, Time.now - start_time]
rescue Exception => e
  puts e
end
end
