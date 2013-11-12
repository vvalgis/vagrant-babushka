require "spec_helper"

describe VagrantPlugins::Babushka::Provisioner do
  let(:config) { double "config" }
  let(:machine) { double "machine", :name => "the name", :communicate => communicate, :env => env }
  let(:communicate) { double "communicate" }
  let(:env) { double "env", :ui => ui }
  let(:ui) { double "ui" }
  let(:provisioner) { described_class.new machine, config }
  subject { provisioner }

  describe "#share_local_deps" do
    let(:root_config) { double "root config", :vm => vm }
    let(:config) { double "config", :local_deps_path => local_deps_path }
    let(:local_deps_path) { double "local deps path", :to_s => "the local deps" }
    let(:vm) { double "root config.vm" }

    it "should configure the directory to be shared" do
      expect(config).to receive(:local_deps_path).and_return(local_deps_path)
      expect(vm).to receive(:synced_folder).with(local_deps_path, "~the\\ user/babushka-deps", {:id => 'babushka_deps', :nfs => false})
      provisioner.username = double "username", :to_s => "the user"
      provisioner.share_local_deps root_config
      subject
    end
  end

  describe "#detect_ssh_group" do
    let(:username) { double "username", :to_s => 'the user' }

    before do
      provisioner.username = username
      expect(communicate).to receive(:execute).with("id -gn the\\ user").and_yield(:stdout, "test\n")
      subject.detect_ssh_group
    end

    its(:group) { should eq "test" }
  end

  describe "#render_messages" do
    let(:config) { double "config", :messages => messages }
    let(:messages) do
      [
        [:warn, "foo bar baz"],
        [:info, "one two three", ['file x line y']],
      ]
    end

    it "should output the mesages" do
      expect(ui).to receive(:send).with(:warn, "vagrant-babushka: foo bar baz", :scope => "the name")
      expect(ui).to receive(:send).with(:info, "vagrant-babushka: one two three\nIn file x line y", :scope => "the name")
      subject.render_messages
    end
  end

  describe "#prepare" do
    context "with Babushka not yet installed" do
      it "should install cURL and Babushka" do
        expect(provisioner).to receive(:in_path?).with("babushka").and_return(false)
        expect(provisioner).to receive(:in_path?).with("curl").and_return(false)
        expect(provisioner).to receive(:install_curl!)
        expect(provisioner).to receive(:create_destination!)
        expect(provisioner).to receive(:install_babushka!)
        expect(ui).to receive(:info).with("\n\n\n")
        subject.prepare
      end

      context "with cURL already installed" do
        it "should install Babushka" do
          expect(provisioner).to receive(:in_path?).with("babushka").and_return(false)
          expect(provisioner).to receive(:in_path?).with("curl").and_return(true)
          expect(provisioner).to_not receive(:install_curl!)
          expect(provisioner).to receive(:create_destination!)
          expect(provisioner).to receive(:install_babushka!)
          expect(ui).to receive(:info).with("\n\n\n")
          subject.prepare
        end
      end
    end

    context "with Babushka already installed" do
      it "should not do anything" do
        expect(provisioner).to receive(:in_path?).with("babushka").and_return(true)
        expect(provisioner).to_not receive(:install_babushka!)
        subject.prepare
      end
    end
  end

  describe "#do_babushka_run" do
    let(:deps) { Array.new }
    let(:config) { double "config", :deps => deps }

    context "with no deps specified" do
      it "should log a warning" do
        expect(ui).to receive(:warn).with(<<-END.gsub(/ {10}|\n\Z/, ""), :scope => "the name")
          Didn't find any Babushka deps to be met on the VM.
          Add some to your Vagrantfile: babushka.meet 'my dep'
        END
        subject.do_babushka_run
      end
    end

    context "with deps specified" do
      let(:deps) { [dep1, dep2] }
      let(:dep1) { double "dep 1", :id => "the dep 1" }
      let(:dep2) { double "dep 2", :id => "the dep 2" }

      it "should meet the deps" do
        expect(ui).to receive(:info).with("Provisioning VM using Babushka...", :scope => "the name")
        expect(ui).to receive(:info).with("Meeting Babushka dep 'the dep 1'", :scope => "the name")
        expect(ui).to receive(:info).with("Executing 'foo'...", :scope => "the name")
        expect(ui).to receive(:info).with("Meeting Babushka dep 'the dep 2'", :scope => "the name")
        expect(ui).to receive(:info).with("Executing 'bar'...", :scope => "the name")
        expect(provisioner).to receive(:command_for).with(dep1).twice().and_return("foo")
        expect(communicate).to receive(:execute).with("foo")
        expect(provisioner).to receive(:command_for).with(dep2).twice().and_return("bar")
        expect(communicate).to receive(:execute).with("bar")
        subject.do_babushka_run
      end
    end
  end
end
