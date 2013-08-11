#!/usr/bin/env ruby
require 'json'
require 'rest-client'
$: << '.'
require 'bv'
# require 'byebug'
require 'thread'
require 'peach'

threads_num = 16
size = 13
operators = []
problems = JSON.parse RestClient.get('http://icfp2013lf.herokuapp.com/myproblems?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', nil)
# problems = [JSON.parse(RestClient.post('http://icfp2013lf.herokuapp.com/train?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', {size: 11}.to_json))]
# problems = [JSON.parse(RestClient.post('http://icfp2013lf.herokuapp.com/train?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', nil))]
puts "Got %d problems" % problems.size
# puts problems.to_s
problems = problems.find_all {|a| a['size'] <= size && (!a['solved']) && (a['timeLeft'] || 42) > 0}

puts "Distilled to %d problems" % problems.size

mutex = Mutex.new
problem_slices = problems.each_slice(problems.size/threads_num+1).to_a
p threads_num = problem_slices.size

threads = []
1.upto(threads_num) { |i| threads << Thread.new {
  problem_slices[i-1].each do |problem|
    begin
      ops = problem['operators']
      next unless operators.all?{|x| ops.include? ops}
      p problem
      solutions = BV.generate(size: problem['size'], operators: ops)
      puts "%d solutions total." % solutions.length
      next if solutions.length > 1000000
      reqs = 0
      mutex.synchronize do
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
            solutions = solutions.pselect(threads_num) {|s| s.eval(Integer(result['values'][0])) == Integer(result['values'][1])}
          else
            raise "unknown response: #{result}"
          end
          raise "couldn't solve!!" if solutions.length < 1
        end
        puts "Solved in %d requests (%s s).\n" % [reqs, Time.now - start_time]
      end
    rescue Exception => e
      puts e
    end
  end      
  }
}
threads.each {|t| t.join }

