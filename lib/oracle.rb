require 'addressable/template'

module Oracle
  UPSTREAM = Addressable::Template.new "http://icfpc2013.cloudapp.net{/path}{?auth}"

  def self.call method: nil, path: "", auth: "", payload: nil
    method ||= payload.nil? ? :get : :post
    RestClient::Request.execute(method: method,
      url: UPSTREAM.expand(path: path, auth: auth).to_str,
      payload: payload,
      headers: {}) do |response, request, result, &block|
        response
    end
  end
end
