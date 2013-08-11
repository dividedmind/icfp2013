#!/usr/bin/env ruby
require 'json'
require 'rest-client'
$: << '.'
require 'bv'
# require 'byebug'
require 'thread'
require 'peach'

start_inputs = (1..64).map{|x| [x, 2**(x-1), 2**(x-1)-1]}.flatten
start_inputs += (1..32).map{|x| [(2**(x-1))^((1<<64)-1), 2**(x-1)+2**(x/2)]}.flatten
start_inputs += [0,257,263,269,271,277,281,283,787,7151,65537,602257,5534429,50859013,467373287,4294967311,39468974959,362703572713,3333095978617]
start_inputs = start_inputs.uniq.sort.map{|x|"0x%016x" % x}

threads_num = 16
size = 13
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
      p problem
      solutions = BV.generate(size: problem['size'], operators: ops)
      puts "%d solutions total." % solutions.length
      classes = solutions.group_by{ |s| start_inputs.map{|x| s.eval(Integer(x))}}
      mutex.synchronize do
        start_time = Time.now
        result = JSON.parse(RestClient.post('http://icfp2013lf.herokuapp.com/eval?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', {id: problem["id"], arguments: start_inputs}.to_json))
        clss = result['outputs'].map{|x|Integer(x)}
        # result = nil
        p classes[clss].size
        solutions = classes[clss]

        # next if solutions.length > 100000
        reqs = 0
        solutions.shuffle!


        
        mismatched = []
        while solutions.length > 0
          puts "%d solutions left." % solutions.length
          if mismatched.size > 0
            solutions = solutions.drop_while do |s|
              mismatched.any? do |m|
                s.eval(Integer(m[0])) != Integer(m[1])
              end
            end
          end
          sol = solutions.first
          program = sol.to_s
          puts program
          reqs += 1
          result = JSON.parse(RestClient.post('http://icfp2013lf.herokuapp.com/guess?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', {id: problem["id"], program: program}.to_json))
          p result
          case result['status']
          when 'win'
            break
          when 'mismatch'
            # solutions.reject! {|s| s.eval(Integer(mismatched.last[0])) != Integer(mismatched.last[1])} if mismatched.size > 0
            mismatched << result['values']
            
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

