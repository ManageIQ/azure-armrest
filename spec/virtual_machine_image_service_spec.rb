########################################################################
# virtual_machine_extension_service_spec.rb
#
# Specs for the Azure::Armrest::VirtualMachineImageService class.
########################################################################

require 'spec_helper'

describe "VirtualMachineImageService" do
  before { setup_params }

  let(:vmis) { Azure::Armrest::VirtualMachineImageService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      ancestors = Azure::Armrest::VirtualMachineImageService.ancestors
      expect(ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns the expected instance type" do
      expect(vmis).to be_kind_of(Azure::Armrest::VirtualMachineImageService)
    end
  end

  context "accessors" do
    it "defines a location accessor" do
      expect(vmis).to respond_to(:location)
      expect(vmis).to respond_to(:location=)
    end

    it "defines a publisher accessor" do
      expect(vmis).to respond_to(:publisher)
      expect(vmis).to respond_to(:publisher=)
    end
  end

  context "instance methods" do
    it "defines an list_all method" do
      expect(vmis).to respond_to(:list_all)
    end

    it "defines an offers method" do
      expect(vmis).to respond_to(:offers)
    end

    it "defines an publishers method" do
      expect(vmis).to respond_to(:publishers)
    end

    it "defines an skus method" do
      expect(vmis).to respond_to(:skus)
    end

    it "defines an versions method" do
      expect(vmis).to respond_to(:versions)
    end

    it "defines an extension method" do
      expect(vmis).to respond_to(:extension)
    end

    it "defines an extension_types method" do
      expect(vmis).to respond_to(:extension_types)
    end

    it "defines an extension_type_versions method" do
      expect(vmis).to respond_to(:extension_type_versions)
    end
  end
end
