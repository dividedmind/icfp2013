class ProblemController < ApplicationController
  def index
    problems = Problem.where(kind: "contest").order_by(:size.asc)
    problems = Problem.download if problems.empty?
    render json: problems
  end
  
  def guess
    id = params[:id]
    program = params[:program]
    
    
    params[:path] = "guess"

    problem = Problem[id]
    
    Rails.logger.info "Guessing #{id} (#{problem.inspect})"
    
    if problem
      if problem.solved?
        render text: "Solved", status: 412
      elsif problem.expired?
        render text: "Gone", status: 410
      else
        response = call_oracle
        resp = JSON.parse(response.body) rescue {}
        if resp["status"] == "win"
          problem.update solved: true, solution: program
        elsif response.code == 412
          problem.update solved: true
        elsif response.code == 410
          problem.update expires_at: Time.now
        end
        render_response response
      end
    else
      proxy
    end
  end
  
  def train
    params[:path] = "train"
    response = call_oracle
    begin
      resp = JSON.parse response.body
      Problem.create id: resp['id'], size: resp['size'], operators: resp['operators'], solution: resp['challenge'], kind: 'train'
    rescue
    end
    
    render_response response
  end
end
