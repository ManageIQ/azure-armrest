require 'azure-signature'
require 'active_support/core_ext/hash/conversions'
require 'nokogiri'

module Azure
  module Armrest
    class StorageAccount < BaseModel
      # Classes used to wrap container and blob information.
      class Container < BaseModel; end
      class Blob < BaseModel; end
      class BlobServiceProperty < BaseModel; end
      class BlobServiceStat < BaseModel; end
      class BlobMetadata < BaseModel; end

      # The version string used in headers sent as part any internal http
      # request. The default is 2015-02-21.
      attr_accessor :storage_api_version

      def initialize(json)
        super
        @storage_api_version = '2015-02-21'
      end

      # Return a list of container names for the given storage account +key+.
      # If no key is provided, it is assumed that the StorageAccount object
      # includes the key1 property.
      #
      def containers(key = nil)
        key ||= properties.key1

        response = blob_response(key, "comp=list")

        Nokogiri::XML(response.body).xpath('//Containers/Container').map do |element|
          Container.new(Hash.from_xml(element.to_s)['Container'])
        end
      end

      # Return a list of blobs for the given +container+ using the given +key+
      # or the key1 property of the StorageAccount object.
      #
      def blobs(container, key = nil)
        key ||= properties.key1

        url = File.join(properties.primary_endpoints.blob, container)
        url += "?restype=container&comp=list"

        headers = build_headers(url, key)
        response = RestClient.get(url, headers)
        doc = Nokogiri::XML(response.body)

        doc.xpath('//Blobs/Blob').map do |node|
          blob = Blob.new(Hash.from_xml(node.to_s)['Blob'])
          blob[:container] = container
          blob
        end
      end

      # Returns an array of all blobs for all containers.
      #
      def all_blobs(key = nil)
        key ||= properties.key1
        array = []
        threads = []

        containers(key).each do |container|
          threads << Thread.new(container, key) { |c, k| array << blobs(c.name, k) }
        end

        threads.each(&:join)

        array.flatten
      end

      # Returns the blob service properties for the current storage account.
      #
      def blob_properties(key = nil)
        key ||= properties.key1

        response = blob_response(key, "restype=service&comp=properties")
        toplevel = 'StorageServiceProperties'

        doc = Nokogiri::XML(response.body).xpath("//#{toplevel}")
        BlobServiceProperty.new(Hash.from_xml(doc.to_s)[toplevel])
      end

      # Return metadata for the given +blob+ within +container+. You may
      # specify a +date+ to retrieve metadata for a specific snapshot.
      #
      def blob_metadata(container, blob, date = nil, key = nil)
        key ||= properties.key1

        query = "comp=metadata"
        query << "&snapshot=#{date}" if date

        response = blob_response(key, query, container, blob)

        BlobMetadata.new(response.headers)
      end

      # Retrieves statistics related to replication for the Blob service. Only
      # available on the secondary location endpoint when read-access
      # geo-redundant replication is enabled for the storage account.
      #
      def blob_service_stats(key = nil)
        key ||= properties.key1

        response = blob_response(key, "restype=service&comp=stats")
        toplevel = 'StorageServiceStats'

        doc = Nokogiri::XML(response.body).xpath("//#{toplevel}")
        BlobServiceStat.new(Hash.from_xml(doc.to_s)[toplevel])
      end

      private

      # Using the blob primary endpoint as a base, join any arguments to the
      # the url and submit an http request.
      #
      def blob_response(key, query, *args)
        url = File.join(properties.primary_endpoints.blob, *args) + "?#{query}"
        headers = build_headers(url, key)
        RestClient.get(url, headers)
      end

      # Set the headers needed, including the Authorization header.
      #
      def build_headers(url, key)
        sig = Signature.new(url, key)

        headers = {
          'x-ms-date'     => Time.now.httpdate,
          'x-ms-version'  => @storage_api_version,
          :auth_string    => true
        }

        headers['Authorization'] = sig.blob_signature(headers)

        headers
      end
    end
  end
end
