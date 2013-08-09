require 'oracle'

class StatusController < ApplicationController
  def show
    render json: Status.fresh
  end
end
