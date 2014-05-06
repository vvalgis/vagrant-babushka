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

  describe "#sudo" do
    subject { dep.sudo }
    it { should be_empty }
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
  end

  context "with params" do
    let(:options) { {:params => params} }
    let(:params) { {:foo => :bar, :baz => :qux} }

    describe "#params" do
      subject { dep.params }
      it { should be params }
    end
  end

  context "with arguments" do
    let(:options) { {:color => color, :source => source} }
    let(:color) { double "color" }
    let(:source) { double "source" }

    describe "#arguments" do
      subject { dep.arguments }
      it { should eq({:color => color})  }
    end
  end

  context "with sudo" do
    let(:options) { {:run_with_sudo => true} }

    describe "#sudo" do
      subject { dep.sudo }
      it { should eq 'sudo' }
    end
  end
end
