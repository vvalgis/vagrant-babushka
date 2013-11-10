require "spec_helper"

describe VagrantPlugins::Babushka::Config do
  let(:unset_value) { described_class::UNSET_VALUE }
  let(:config) { described_class.new }

  context "with default configuration" do
    before { subject.finalize! }
    its(:deps) { should eq [] }
    its(:local_deps_path) { should be_nil }
    its(:bootstrap_branch) { should be_nil }
  end

  describe "#local_deps_path" do
    before { subject.local_deps_path = '.deps' }
    its(:local_deps_path) { should eq '.deps' }
  end

  describe "#bootstrap_branch" do
    before { subject.bootstrap_branch = 'new' }
    its(:bootstrap_branch) { should eq 'new' }
  end

  describe "#local_dep" do
    before do
      subject.local_dep 'foobar', :baz => :qux
      subject.local_dep 'testme', :one => :two
    end

    it "should store the deps correctly" do
      expect(subject.deps).to eq [
        VagrantPlugins::Babushka::Dep.new('foobar', :params => {:baz => :qux}),
        VagrantPlugins::Babushka::Dep.new('testme', :params => {:one => :two}),
      ]
    end
  end

  describe "#remote_dep" do
    before do
      subject.remote_dep 'user1', 'foobar', :baz => :qux
      subject.remote_dep 'user2', 'testme', :one => :two
    end

    it "should store the deps correctly" do
      expect(subject.deps).to eq [
        VagrantPlugins::Babushka::Dep.new('foobar', :params => {:baz => :qux}, :source => 'user1'),
        VagrantPlugins::Babushka::Dep.new('testme', :params => {:one => :two}, :source => 'user2'),
      ]
    end
  end
end
