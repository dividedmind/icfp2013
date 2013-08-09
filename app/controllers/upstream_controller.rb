require 'addressable/template'

class UpstreamController < ApplicationController
  UPSTREAM = Addressable::Template.new "http://icfpc2013.cloudapp.net{/path}{?auth}"
  
  # Just proxy the request. Add in the auth key if not present.
  def proxy
    response = RestClient::Request.execute method: request.method.downcase.to_sym,
        url: UPSTREAM.expand(path: params.delete(:path), auth: (params.delete(:auth) || ENV['ICFP_AUTH_KEY'])).to_str,
        payload: request.body,
        headers: {}
    render text: response
  end
end
