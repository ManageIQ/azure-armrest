require 'azure-signature'
require 'active_support/core_ext/hash/conversions'
require 'nokogiri'

module Azure
  module Armrest
    class StorageAccount < BaseModel
      # Classes used to wrap container and blob information.
      class Container < BaseModel; end
      class ContainerProperty < BaseModel; end
      class Blob < BaseModel; end
      class BlobProperty < BaseModel; end
      class PrivateImage < BlobProperty; end
      class BlobServiceProperty < BaseModel; end
      class BlobServiceStat < BaseModel; end
      class BlobMetadata < BaseModel; end
      class BlobSnapshot < Blob; end

      # Classes used to wrap table information
      class Table < BaseModel; end
      class TableData < BaseModel; end

      # The version string used in headers sent as part any internal http
      # request. The default is 2015-02-21.
      attr_accessor :storage_api_version

      def initialize(json)
        super
        @storage_api_version = '2015-02-21'
      end

      # Returns a list of tables for the given storage account +key+. Note
      # that full metadata is returned.
      #
      def tables(key = nil)
        key ||= properties.key1
        response = table_response(key, nil, "Tables")
        JSON.parse(response.body)['value'].map{ |t| Table.new(t) }
      end

      # Return information about a single table for the given storage
      # account +key+. If you are looking for the entities within the
      # table, use the table_data method instead.
      #
      def table_info(table, key = nil)
        key ||= properties.key1
        response = table_response(key, nil, "Tables('#{table}')")
        Table.new(response.body)
      end

      # Returns a list of TableData objects for the given table +name+ using
      # account +key+. The exact nature of the TableData object depends on the
      # type of table that it is.
      #
      def table_data(name, key = nil, options = {})
        key ||= properties.key1

        query = ""

        hash = {
          "$filter=" => options[:filter],
          "$select=" => options[:select],
          "$top="    => options[:top]
        }

        hash.each do |key, value|
          if query.include?("$")
            query << "&#{key}#{value}" if value
          else
            query << "#{key}#{value}" if value
          end
        end

        response = table_response(key, query, name)
        JSON.parse(response.body)['value'].map{ |t| TableData.new(t) }
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

      # Returns the properties for the given container +name+ using account +key+.
      # If no key is provided, it is assumed that the StorageAccount object
      # includes the key1 property.
      #
      def container_properties(name, key = nil)
        key ||= properties.key1

        response = blob_response(key, "restype=container", name)

        ContainerProperty.new(response.headers)
      end

      # Returns the properties for the given container +name+ using account +key+.
      # If no key is provided, it is assumed that the StorageAccount object
      # includes the key1 property.
      #
      # If the returned object does not contain x_ms_blob_public_access then
      # the container is private to the account owner. You can also use the
      # :private? method to determine if the account is public or private.
      #
      def container_acl(name, key = nil)
        key ||= properties.key1

        response = blob_response(key, "restype=container&comp=acl", name)
        response.headers[:private?] = response.headers.include?(:x_ms_blob_public_access) ? false : true

        ContainerProperty.new(response.headers)
      end

      # Return the blob properties for the given +blob+ found in +container+. You may
      # optionally provide a date to get information for a snapshot.
      #
      def blob_properties(container, blob, key = nil, options = {})
        key ||= properties.key1

        url = File.join(properties.primary_endpoints.blob, container, blob)
        url += "?snapshot=" + options[:date] if options[:date]

        headers = build_headers(url, key, :blob, :verb => 'HEAD')
        response = RestClient.head(url, headers)

        BlobProperty.new(response.headers)
      end

      # Return a list of blobs for the given +container+ using the given +key+
      # or the key1 property of the StorageAccount object.
      #
      def blobs(container, key = nil, include_snapshot = false)
        key ||= properties.key1

        url = File.join(properties.primary_endpoints.blob, container)
        url += "?restype=container&comp=list"
        url += "&include=snapshots" if include_snapshot

        headers = build_headers(url, key)
        response = RestClient.get(url, headers)
        doc = Nokogiri::XML(response.body)

        doc.xpath('//Blobs/Blob').map do |node|
          hash = Hash.from_xml(node.to_s)['Blob'].merge(:container => container)
          hash.key?('Snapshot') ? BlobSnapshot.new(hash) : Blob.new(hash)
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
      def blob_service_properties(key = nil)
        key ||= properties.key1

        response = blob_response(key, "restype=service&comp=properties")
        toplevel = 'StorageServiceProperties'

        doc = Nokogiri::XML(response.body).xpath("//#{toplevel}")
        BlobServiceProperty.new(Hash.from_xml(doc.to_s)[toplevel])
      end

      # Return metadata for the given +blob+ within +container+. You may
      # specify a +date+ to retrieve metadata for a specific snapshot.
      #
      def blob_metadata(container, blob, key = nil, options = {})
        key ||= properties.key1

        query = "comp=metadata"
        query << "&snapshot=" + options[:date] if options[:date]

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

      # Copy the blob from the source container/blob to the destination container/blob.
      # If no destination blob name is provided, it will use the same name as the source.
      #
      # Example:
      #
      #   source = "Microsoft.Compute/Images/your_container/your-img-osDisk.123xyz.vhd"
      #   storage_acct.copy_blob('system', source, 'vhds', nil, your_key)
      #
      def copy_blob(src_container, src_blob, dst_container, dst_blob = nil, key = nil)
        key ||= properties.key1
        dst_blob ||= File.basename(src_blob)

        dst_url = File.join(properties.primary_endpoints.blob, dst_container, dst_blob)
        src_url = File.join(properties.primary_endpoints.blob, src_container, src_blob)

        options = {'x-ms-copy-source' => src_url, 'If-None-Match' => '*', :verb => 'PUT'}

        headers = build_headers(dst_url, key, :blob, options)

        # RestClient will set the Content-Type to application/x-www-form-urlencoded.
        # We must override this setting or the request will fail.
        headers['Content-Type'] = ''

        response = RestClient.put(dst_url, '', headers)

        Blob.new(response.headers)
      end

      # Delete the given +blob+ found in +container+.
      #
      def delete_blob(container, blob, key = nil, options = {})
        key ||= properties.key1

        url = File.join(properties.primary_endpoints.blob, container, blob)
        url += "?snapshot=" + options[:date] if options[:date]

        headers = build_headers(url, key, :blob, :verb => 'DELETE')
        response = RestClient.delete(url, headers)

        true
      end

      def create_blob_snapshot(container, blob, key = nil)
        key ||= properties.key1

        url = File.join(properties.primary_endpoints.blob, container, blob)
        url += "?comp=snapshot"

        headers = build_headers(url, key, :blob, :verb => 'PUT')
        headers['Content-Type'] = ''
        response = RestClient.put(url, '', headers)

        BlobSnapshot.new(
          'name'          => blob,
          'last_modified' => response.headers.fetch(:last_modified),
          'snapshot'      => response.headers.fetch(:x_ms_snapshot)
        )
      end

      private

      # Using the blob primary endpoint as a base, join any arguments to the
      # the url and submit an http request.
      #
      def blob_response(key, query, *args)
        url = File.join(properties.primary_endpoints.blob, *args) + "?#{query}"
        headers = build_headers(url, key, 'blob')
        RestClient.get(url, headers)
      end

      # Using the blob primary endpoint as a base, join any arguments to the
      # the url and submit an http request.
      def table_response(key, query = nil, *args)
        url = File.join(properties.primary_endpoints.table, *args)

        headers = build_headers(url, key, 'table')
        headers['Accept'] = 'application/json;odata=fullmetadata'

        url << "?#{query}" if query # Must happen after headers are built

        RestClient.get(url, headers)
      end

      # Set the headers needed, including the Authorization header.
      #
      def build_headers(url, key, sig_type = nil, additional_headers = {})
        sig = Signature.new(url, key)
        sig_type ||= 'blob'

        headers = {
          'x-ms-date'     => Time.now.httpdate,
          'x-ms-version'  => @storage_api_version,
          :auth_string    => true
        }

        headers.merge!(additional_headers)
        headers['Authorization'] = sig.signature(sig_type, headers)

        headers
      end
    end
  end
end
