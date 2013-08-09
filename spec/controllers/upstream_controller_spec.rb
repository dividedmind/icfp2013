require 'spec_helper'

describe UpstreamController do
  describe "GET example_path?auth=testkey", proxy: true do
    let(:path) { 'example_path' }
    let(:invoke!) { get :proxy, path: path, auth: 'testkey' }
    it_proxies
  end
end
