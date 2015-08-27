########################################################################
# virtual_machine_extension_service_spec.rb
#
# Specs for the Azure::Armrest::VirtualMachineExtensionService class.
########################################################################

require 'spec_helper'

describe "VirtualMachineExtensionService" do
  before { setup_params }
  let(:vmes) { Azure::Armrest::VirtualMachineExtensionService.new(@conf) }

  context "inheritance" do
    it "is a subclass of VirtualMachineService" do
      ancestors = Azure::Armrest::VirtualMachineExtensionService.ancestors
      expect(ancestors).to include(Azure::Armrest::VirtualMachineService)
    end
  end

  context "constructor" do
    it "returns a VMES instance as expected" do
      expect(vmes).to be_kind_of(Azure::Armrest::VirtualMachineExtensionService)
    end
  end

  context "accessors" do
    it "defines a base_url accessor" do
      expect(vmes).to respond_to(:base_url)
      expect(vmes).to respond_to(:base_url=)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(vmes).to respond_to(:create)
    end

    it "defines an update alias" do
      expect(vmes).to respond_to(:update)
      expect(vmes.method(:update)).to eql(vmes.method(:create))
    end

    it "defines a delete method" do
      expect(vmes).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(vmes).to respond_to(:get)
    end

    it "defines a list method" do
      expect(vmes).to respond_to(:list)
    end
  end
end
