require 'addressable/template'
require 'json'

module Oracle
  UPSTREAM = Addressable::Template.new "http://icfpc2013.cloudapp.net{/path}{?auth}"

  class << self
    def call method: nil, path: "", auth: "", payload: nil
      method ||= payload.nil? ? :get : :post
      RestClient::Request.execute(method: method,
        url: UPSTREAM.expand(path: path, auth: auth).to_str,
        payload: payload,
        headers: {}) do |response, request, result, &block|
          response
      end
    end
    
    def auth_key
      @auth_key ||= ENV['ICFP_AUTH_KEY']
    end
    
    # !! adds in the auth key
    def get path
      response = call path: path.to_s, auth: auth_key
      result = JSON.parse(response.body) rescue { body: response.body }
      result[:status_code] = response.code
      return result
    end
    
    def method_missing name
      get name
    end
  end
end
