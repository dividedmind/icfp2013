#!/usr/bin/env ruby
require 'json'
require 'rest-client'
$: << '.'
require 'bv'

size = 6
operators = []
#problems = JSON.parse RestClient.get('http://icfp2013lf.herokuapp.com/myproblems?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', nil)
problems = [JSON.parse(RestClient.post('http://icfp2013lf.herokuapp.com/train?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', {size: size, operators: operators}.to_json))]
problems = problems.find_all {|a| a['size'] == size && (!a['solved']) && (a['timeLeft'] || 42) > 0}
#problems = [{"id"=>"3OVf2IsEAbkuaqElXg7Ax3je", "size"=>5, "operators"=>["or", "shl1"], "solved"=>false, "expires_at"=>nil, "solution"=>nil, "kind"=>"contest"}]
problems.each do |problem|
  ops = problem['operators']
  next unless operators.all?{|x| ops.include? ops}
  p problem
  solutions = BV.generate size: problem['size'], operators: ops
  puts "%d solutions" % solutions.length
  next if solutions.length > 25
  reqs = 0
  start_time = Time.now
  solutions.shuffle.each do |sol|
    program = sol.to_s
    puts program
    reqs += 1
    result = JSON.parse(RestClient.post('http://icfp2013lf.herokuapp.com/guess?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', {id: problem["id"], program: program}.to_json)) rescue {}
    p result
    break if result['status'] == 'win'
    raise "couldn't solve!!" if reqs == solutions.length
  end
  puts "Solved in %d requests (%s s)." % [reqs, Time.now - start_time]
end
