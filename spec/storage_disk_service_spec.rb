########################################################################
# storage_disk_service_spec.rb
#
# Test suite for the Azure::Armrest::Storage::DiskService class.
########################################################################
require 'spec_helper'

describe "Storage::DiskService" do
  before { setup_params }
  let(:disk) { Azure::Armrest::Storage::DiskService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Storage::DiskService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns an DiskService instance as expected" do
      expect(disk).to be_kind_of(Azure::Armrest::Storage::DiskService)
    end
  end

  context "instance methods" do
    it "defines a create method" do
      expect(disk).to respond_to(:create)
    end

    it "defines an update alias" do
      expect(disk).to respond_to(:update)
      expect(disk.method(:update)).to eql(disk.method(:create))
    end

    it "defines a delete method" do
      expect(disk).to respond_to(:delete)
    end

    it "defines a get method" do
      expect(disk).to respond_to(:get)
    end

    it "defines a stop method" do
      expect(disk).to respond_to(:list)
    end

    it "defines a get_blob_raw method" do
      expect(disk).to respond_to(:get_blob_raw)
    end

    it "defines a open method" do
      expect(disk).to respond_to(:open)
    end

    it "defines a read method" do
      expect(disk).to respond_to(:read)
    end

    it "defines a close method" do
      expect(disk).to respond_to(:read)
    end
  end

  context "open" do
    it "requires a disk name and resource group" do
      expect { disk.open }.to raise_error(ArgumentError)
      expect { disk.open('foo', nil) }.to raise_error(ArgumentError)
    end

    it "will raise an error if it cannot acquire an access token" do
      headers = Azure::Armrest::ResponseHeaders.new(:headers => {:stuff => 1}, :code => 404, :body => "oops")

      allow(disk).to receive(:wait).and_return('failed')
      allow(disk).to receive(:rest_post).and_return(headers)

      expect { disk.open('foo', 'bar') }.to raise_error(Azure::Armrest::NotFoundException, /Unable to obtain an operations URL/)
    end
  end

  context "read" do
    it "requires a sas url" do
      expect { disk.read }.to raise_error(ArgumentError)
    end

    it "will raise an error if :entire_image is not specified and no range is specified" do
      headers = Azure::Armrest::ResponseHeaders.new(:headers => {:azure_asyncoperation => "https://www.foo.bar"})
      body    = Azure::Armrest::ResponseBody.new(:body => {:properties => {:output => {:access_sas => 'xyz'}}})

      allow(disk).to receive(:wait).and_return('succeeded')
      allow(disk).to receive(:rest_post).and_return(headers)
      allow(disk).to receive(:rest_get).and_return(body)

      expect { disk.read('foo', 'bar') }.to raise_error(ArgumentError, /must specify byte range/)
    end
  end

  context "get_blob_raw" do
    it "requires a disk name and resource group" do
      expect { disk.get_blob_raw }.to raise_error(ArgumentError)
      expect { disk.get_blob_raw('foo', nil) }.to raise_error(ArgumentError)
    end

    it "will raise an error if :entire_image is not specified and no range is specified" do
      headers = Azure::Armrest::ResponseHeaders.new(:headers => {:azure_asyncoperation => "https://www.foo.bar"})
      body    = Azure::Armrest::ResponseBody.new(:body => {:properties => {:output => {:access_sas => 'xyz'}}})

      allow(disk).to receive(:wait).and_return('succeeded')
      allow(disk).to receive(:rest_post).and_return(headers)
      allow(disk).to receive(:rest_get).and_return(body)

      expect { disk.get_blob_raw('foo', 'bar') }.to raise_error(ArgumentError, /must specify byte range/)
    end

    it "will raise an error if it cannot acquire an access token" do
      headers = Azure::Armrest::ResponseHeaders.new(:headers => {:stuff => 1}, :code => 404, :body => "oops")

      allow(disk).to receive(:wait).and_return('failed')
      allow(disk).to receive(:rest_post).and_return(headers)

      expect { disk.get_blob_raw('foo', 'bar') }.to raise_error(Azure::Armrest::NotFoundException, /Unable to obtain an operations URL/)
    end
  end
end
