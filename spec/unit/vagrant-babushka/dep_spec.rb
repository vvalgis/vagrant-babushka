require "spec_helper"

describe VagrantPlugins::Babushka::Dep do
  let(:dep_name) { double "dep_name", :to_s => "the dep" }
  let(:options) { Hash.new }
  let(:dep) { described_class.new dep_name, options }
  let(:subject) { dep }

  describe "#dep_name" do
    subject { dep.dep_name }
    it { should eq dep_name.to_s }
  end

  describe "#id" do
    subject { dep.id }
    it { should eq dep_name.to_s }
  end

  describe "#source" do
    subject { dep.source }
    it { should be_nil }
  end

  describe "#command" do
    subject { dep.command }
    it { should eq "the\\ dep" }
  end

  context "with source" do
    let(:options) { {:source => source} }
    let(:source) { double "source", :to_s => "the source" }

    describe "#id" do
      subject { dep.id }
      it { should eq "#{source}:#{dep_name}" }
    end

    describe "#source" do
      subject { dep.source }
      it { should eq source.to_s }
    end

    describe "#command" do
      subject { dep.command }
      it { should eq "the\\ source:the\\ dep" }
    end
  end

  context "with params" do
    let(:options) { {:params => params} }
    let(:params) { {:foo => :bar, :baz => :qux} }

    describe "#params" do
      subject { dep.params }
    end

    describe "#command" do
      subject { dep.command }
      it { should eq "the\\ dep foo=bar baz=qux" }
    end
  end

  context "with source and params" do
    let(:options) { {:params => params, :source => source} }
    let(:params) { {:foo => :bar, :baz => :qux} }
    let(:source) { double "source", :to_s => "the source" }

    describe "#command" do
      subject { dep.command }
      it { should eq "the\\ source:the\\ dep foo=bar baz=qux" }
    end
  end
end
