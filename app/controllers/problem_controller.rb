class ProblemController < ApplicationController
  def index
    problems = Problem.order_by(:size.asc)
    problems = Problem.download if problems.empty?
    render json: problems
  end
end
