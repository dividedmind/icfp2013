require 'oracle'

class UpstreamController < ApplicationController
  # Just proxy the request.
  def proxy
    response = Oracle.call method: request.method.downcase.to_sym,
        path: params[:path],
        auth: params[:auth],
        payload: request.body
    render text: response.body, status: response.code, content_type: response.headers[:content_type]
  end
end
