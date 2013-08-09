require 'spec_helper'

describe ProblemController do
  describe "POST guess", proxy: true do
    let(:invoke!) { post :guess, '{"id": "foo", "program": "bar"}', auth: 'testkey', id: 'foo', program: 'bar' }
    let(:path) { "guess" }
    let(:request_body) { '{"id": "foo", "program": "bar"}' }
    let(:body) { '{"status": "error"}' }

    context "when the problem is not known" do
      it_proxies
    end
    
    context "when the problem is known" do
      context "and expired" do
        before do
          Problem.create id: 'foo', size: 0, operators: [], expires_at: 2.seconds.ago
        end
        it "returns 410 Gone" do
          invoke!
          expect(response.status).to eql(410)
        end
      end
      
      context "and solved" do
        before do
          Problem.create id: 'foo', size: 0, operators: [], expires_at: 2.seconds.ago, solved: true
        end
        it "returns 412" do
          invoke!
          expect(response.status).to eql(412)
        end
      end
      
      context "and unsolved" do
        before do
          Problem.create id: 'foo', size: 0, operators: [], expires_at: 3.hours.from_now, solved: false
        end
        
        it_proxies
        
        context "and the guess is right" do
          let(:body) { '{"status": "win"}' }
          it "marks the problem as solved" do
            invoke!
            expect(Problem['foo']).to be_solved
          end
          it "records the solution" do
            invoke!
            expect(Problem['foo'].solution).to eql("bar")
          end
        end
        
        context "and the guess is wrong" do
          let(:body) { '{"status": "mismatch"}' }
          it "not marks the problem as solved" do
            invoke!
            expect(Problem['foo']).to_not be_solved
          end
        end
        
        context "and the upstream said 410" do
          let(:status) { 410 }
          it "marks it expired" do
            invoke!
            expect(Problem['foo']).to be_expired
          end
        end
        
        context "and the upstream said 412" do
          let(:status) { 412 }
          it "marks it solved" do
            invoke!
            expect(Problem['foo']).to be_solved
          end
        end
      end
    end
  end

  describe "POST train", proxy: true do
    let(:invoke!) { post :train, '{"size": 3}', auth: 'testkey', size: 3 }
    let(:path) { "train" }
    let(:request_body) { '{"size": 3}' }
    let(:body) { '{"id":"i3ttAniE5Yh5CIrwZcQAh35Ax8","size":3,"operators":["or"],"challenge":"(lambda (x) (or x x))"}' }
    it "adds the problem to the db" do
      invoke!
      pm = Problem['i3ttAniE5Yh5CIrwZcQAh35Ax8']
      pm.size.should == 3
      pm.operators.should == %w(or)
      pm.solution.should == "(lambda (x) (or x x))"
      pm.kind.should == 'train'
    end
  end
end
