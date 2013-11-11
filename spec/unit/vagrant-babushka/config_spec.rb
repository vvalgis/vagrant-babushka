require "spec_helper"

describe VagrantPlugins::Babushka::Config do
  let(:unset_value) { described_class::UNSET_VALUE }
  let(:config) { described_class.new }
  subject { config }

  context "with default configuration" do
    before { config.finalize! }
    its(:deps) { should eq [] }
    its(:local_deps_path) { should be_nil }
    its(:bootstrap_branch) { should be_nil }
  end

  describe "#local_deps_path" do
    before { config.local_deps_path = '.deps'; config.finalize! }
    its(:local_deps_path) { should eq '.deps' }
  end

  describe "#bootstrap_branch" do
    before { config.bootstrap_branch = 'new'; config.finalize! }
    its(:bootstrap_branch) { should eq 'new' }
    its(:bootstrap_url) { should eq 'https://babushka.me/up/new' }
  end

  describe "#bootstrap_url" do
    before do
      config.bootstrap_url = 'https://example.com/foo'
      config.finalize!
    end

    its(:bootstrap_url) { should eq 'https://example.com/foo' }
  end

  describe "#arguments" do
    before do
      config.color = false
      config.debug = true
      config.dry_run = true
      config.bootstrap_url = double "bootstrap_url"
      config.finalize!
    end

    subject { config.arguments }

    specify "set values should override defaults" do
      expect(subject).to eq({
        :color => false,
        :debug => true,
        :dry_run => true,
        :show_args => false,
        :silent => false,
        :update => true,
      })
    end
  end

  describe "#local_dep" do
    before do
      config.local_dep 'foobar', :baz => :qux
      config.local_dep 'testme', :one => :two
      config.finalize!
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
      config.remote_dep 'user1', 'foobar', :baz => :qux
      config.remote_dep 'user2', 'testme', :one => :two
      config.finalize!
    end

    it "should store the deps correctly" do
      expect(subject.deps).to eq [
        VagrantPlugins::Babushka::Dep.new('foobar', :params => {:baz => :qux}, :source => 'user1'),
        VagrantPlugins::Babushka::Dep.new('testme', :params => {:one => :two}, :source => 'user2'),
      ]
    end
  end

  describe "#meet" do
    before {
      config.meet 'test1', :source => 'user1', :params => {:abc => :def}
      config.meet 'test2', :source => 'user2', :params => {:ghi => :jkl}
      config.finalize!
    }

    it "should store the deps correctly" do
      expect(subject.deps).to eq [
        VagrantPlugins::Babushka::Dep.new('test1', :params => {:abc => :def}, :source => 'user1'),
        VagrantPlugins::Babushka::Dep.new('test2', :params => {:ghi => :jkl}, :source => 'user2'),
      ]
    end
  end
end
