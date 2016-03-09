########################################################################
# virtual_machine_spec.rb
#
# Test suite for the Azure::Armrest::VirtualMachine model class.
########################################################################
require 'spec_helper'

describe "VirtualMachineInstance" do
	
  before { setup_params }
  let(:vms) { Azure::Armrest::VirtualMachineService.new(@conf) }
	let(:base) { Azure::Armrest::VirtualMachine.new(vms) }

	context "constructor" do
		it "constructs a VirtualMachine instance from a hash" do
			expect(base).to be_kind_of(Azure::Armrest::VirtualMachine)
		end
	end

	context "instance methods" do
    it "defines a capture method" do
      expect(base).to respond_to(:capture)
    end

    it "defines a deallocate method" do
      expect(base).to respond_to(:deallocate)
    end

    it "defines a delete method" do
      expect(base).to respond_to(:delete)
    end

    it "defines a generalize method" do
      expect(base).to respond_to(:generalize)
    end

    it "defines an restart method" do
      expect(vms).to respond_to(:restart)
    end

    it "defines a start method" do
      expect(vms).to respond_to(:start)
    end

    it "defines a stop method" do
      expect(vms).to respond_to(:stop)
    end
  end
end
