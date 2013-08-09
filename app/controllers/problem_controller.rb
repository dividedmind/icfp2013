class ProblemController < ApplicationController
  def index
    problems = Problem.all
    problems = Problem.download if problems.empty?
    render json: problems
  end
end
