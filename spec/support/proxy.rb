shared_context "a proxy", proxy: true do
    let(:body) { 'hello world' }
    let(:status) { 200 }
    
    before do
      stub_request(:any, "http://icfpc2013.cloudapp.net/#{path}?auth=testkey").with(
        body: (request_body rescue nil)
      ).to_return(:status => status, :body => body, :headers => {})
    end
    
    def self.it_proxies 
      it "proxies to upstream" do
        invoke!
        expect(response.body).to eql(body)
      end
    end
  end
