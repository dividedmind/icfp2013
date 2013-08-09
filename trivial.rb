#!/usr/bin/env ruby
require 'json'
require 'rest-client'

#problems = JSON.parse RestClient.post('http://icfp2013lf.herokuapp.com/myproblems?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', nil)
problems = [JSON.parse(RestClient.post('http://icfp2013lf.herokuapp.com/train?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', {size: 8, operators: ['tfold']}.to_json))]
trivial = problems.find_all {|a| a['size'] == 8 && (!a['solved'])}
trivial.each do |problem|
  ops = problem['operators']
  next unless ops.include? "tfold"
  next unless ops.length == 2
  p problem
  op = (ops - ["tfold"]).first
  program = "(lambda (x) (fold x 0 (lambda (x y) (#{op} x y))))"
  puts program
  p RestClient.post('http://icfp2013lf.herokuapp.com/guess?auth=0229KtQKyHAgd8LaD0JPubHAC9InNBjCPTxnhVQBvpsH1H', {id: problem["id"], program: program}.to_json) rescue nil
end
