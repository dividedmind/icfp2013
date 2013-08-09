require 'spec_helper'

describe UpstreamController do
  describe "GET example_path?auth=fookey" do
    let(:body) { 'hello world' }
    before do
      stub_request(:get, "http://icfpc2013.cloudapp.net/example_path?auth=fookey").
         to_return(:status => 200, :body => body, :headers => {})
    end
    it "proxies to upstream" do
      get :proxy, path: 'example_path', auth: 'fookey'
      expect(response.body).to eql(body)
    end
  end
end
