require 'azure-signature'
require 'active_support/core_ext/hash/conversions'
require 'oga'

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

      # An http proxy to use per request. Defaults to ENV['http_proxy'] if set.
      attr_accessor :proxy

      # The SSL version to use per request. Defaults to TLSv1.
      attr_accessor :ssl_version

      # The SSL verification method used for each request. The default is VERIFY_PEER.
      attr_accessor :ssl_verify

      def initialize(json)
        super
        @storage_api_version = '2015-02-21'
        @proxy = ENV['http_proxy']
        @ssl_version = 'TLSv1'
        @ssl_verify = nil
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
      # You may specify :filter, :select or :top as options to restrict your
      # result set.
      #
      # By default you will receive a maximum of 1000 records. If you wish to
      # receive more records, you will need to use the continuation token. You
      # may also set the :all option to true if you want all records, though we
      # recommend using a filter as well if you use that option as there can
      # be thousands of results.
      #
      # You may also specify a :NextRowKey, :NextPartitionKey or :NextTableset
      # explicitly for paging. Normally you would just pass the
      # collection's continuation_token, however. See below for an example.
      #
      # When using continuation tokens, you should retain your original
      # filtering as well, or you may get unexpected results.
      #
      # Examples:
      #
      #   # Get the first 10 rows of data from the last 3 days
      #   date = (Time.now - (86400 * 3)).iso8601
      #   my_filter = "timestamp ge datetime'#{date}'"
      #   options = {:top => 10, :filter => my_filter}
      #
      #   results = storage_account.table_data(table, key, options)
      #
      #   # Now get the next 10 records
      #   if results.continuation_token
      #     options[:continuation_token] = results.continuation_token
      #     more_results = storage_account.table_data(table, key, options)
      #   end
      #
      def table_data(name, key = nil, options = {})
        key ||= properties.key1

        query = build_query(options)

        response = table_response(key, query, name)
        json_response = JSON.parse(response.body)

        data = ArmrestCollection.new(json_response['value'].map { |t| TableData.new(t) })
        data.continuation_token = parse_continuation_tokens(response)

        if options[:all] && data.continuation_token
          options[:continuation_token] = data.continuation_token
          data.push(*table_data(name, key, options))
          data.continuation_token = nil # Clear when finished
        end

        data
      end

      # Return a list of container names for the given storage account +key+.
      # If no key is provided, it is assumed that the StorageAccount object
      # includes the key1 property.
      #
      def containers(key = nil)
        key ||= properties.key1

        response = blob_response(key, "comp=list")

        Oga.parse_xml(response.body).xpath('//Containers/Container').map do |element|
          Container.new(Hash.from_xml(element.to_xml)['Container'])
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

        response = ArmrestService.send(
          :rest_head,
          :url         => url,
          :headers     => headers,
          :proxy       => proxy,
          :ssl_version => ssl_version,
          :ssl_verify  => ssl_verify
        )

        BlobProperty.new(response.headers)
      end

      # Return a list of blobs for the given +container+ using the given +key+
      # or the key1 property of the StorageAccount object. You may pass a
      # Container object, or just the name of the container.
      #
      def blobs(container, key = nil, include_snapshot = false)
        container = container.respond_to?(:name) ? container.name : container

        key ||= properties.key1

        url = File.join(properties.primary_endpoints.blob, container)
        url += "?restype=container&comp=list"
        url += "&include=snapshots" if include_snapshot

        headers = build_headers(url, key)

        response = ArmrestService.send(
          :rest_get,
          :url         => url,
          :headers     => headers,
          :proxy       => proxy,
          :ssl_version => ssl_version,
          :ssl_verify  => ssl_verify
        )

        doc = Oga.parse_xml(response.body)

        doc.xpath('//Blobs/Blob').map do |node|
          hash = Hash.from_xml(node.to_xml)['Blob'].merge(:container => container)
          hash.key?('Snapshot') ? BlobSnapshot.new(hash) : Blob.new(hash)
        end
      end

      # Returns an array of all blobs for all containers.
      #
      def all_blobs(key = nil)
        key ||= properties.key1
        array = []
        mutex = Mutex.new

        Parallel.each(containers(key), :in_threads => 10) do |container|
          mutex.synchronize { array << blobs(container.name, key) }
        end

        array.flatten
      end

      # Returns the blob service properties for the current storage account.
      #
      def blob_service_properties(key = nil)
        key ||= properties.key1

        response = blob_response(key, "restype=service&comp=properties")
        toplevel = 'StorageServiceProperties'

        doc = Oga.parse_xml(response.body).xpath("//#{toplevel}")
        BlobServiceProperty.new(Hash.from_xml(doc.map(&:to_xml).join(''))[toplevel])
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

        doc = Oga.parse_xml(response.body).xpath("//#{toplevel}")

        BlobServiceStat.new(Hash.from_xml(doc.map(&:to_xml).join(''))[toplevel])
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

        response = ArmrestService.send(
          :rest_put,
          :url         => dst_url,
          :payload     => '',
          :headers     => headers,
          :proxy       => proxy,
          :ssl_version => ssl_version,
          :ssl_verify  => ssl_verify
        )

        Blob.new(response.headers)
      end

      # Delete the given +blob+ found in +container+.
      #
      def delete_blob(container, blob, key = nil, options = {})
        key ||= properties.key1

        url = File.join(properties.primary_endpoints.blob, container, blob)
        url += "?snapshot=" + options[:date] if options[:date]

        headers = build_headers(url, key, :blob, :verb => 'DELETE')

        ArmrestService.send(
          :rest_delete,
          :url         => url,
          :headers     => headers,
          :proxy       => proxy,
          :ssl_version => ssl_version,
          :ssl_verify  => ssl_verify
        )

        true
      end

      # Create new blob for a container.
      #
      # The +data+ parameter is a hash that contains the blob's information:
      #
      # data['x-ms-blob-type']
      # # - Required. Specifies the type of blob to create: block, page or append.
      #
      # data['x-ms-blob-content-encoding']
      # # - Optional. Set the blob’s content encoding.
      # ...
      def create_blob(container, blob, data, key = nil)
        key ||= properties.key1

        url = File.join(properties.primary_endpoints.blob, container, blob)

        options = {:verb => 'PUT'}
        options = options.merge(data)
        headers = build_headers(url, key, :blob, options)

        response = ArmrestService.send(
          :rest_put,
          :url         => url,
          :payload     => '',
          :headers     => headers,
          :proxy       => proxy,
          :ssl_version => ssl_version,
          :ssl_verify  => ssl_verify
        )

        Blob.new(response.headers)
      end

      def create_blob_snapshot(container, blob, key = nil)
        key ||= properties.key1

        url = File.join(properties.primary_endpoints.blob, container, blob)
        url += "?comp=snapshot"

        headers = build_headers(url, key, :blob, :verb => 'PUT')

        response = ArmrestService.send(
          :rest_put,
          :url         => url,
          :payload     => '',
          :headers     => headers,
          :proxy       => proxy,
          :ssl_version => ssl_version,
          :ssl_verify  => ssl_verify
        )

        BlobSnapshot.new(
          'name'          => blob,
          'last_modified' => response.headers.fetch(:last_modified),
          'snapshot'      => response.headers.fetch(:x_ms_snapshot)
        )
      end

      # Get the contents of the given +blob+ found in +container+ using the
      # given +options+. This is a low level method to read a range of bytes
      # from the blob directly. The possible options are:
      #
      # * range        - A range of bytes to collect.
      # * start_byte   - The starting byte for collection.
      # * end_byte     - The end byte for collection. Use this or :length with :start_byte.
      # * length       - The number of bytes to collect starting at +start_byte+.
      # * entire_image - Read all bytes for the blob.
      # * md5          - If true, the response headers will include MD5 checksum information.
      # * date         - Get the blob snapshot for the given date.
      #
      # If you do not specify a :range or :start_byte, then an error will be
      # raised unless you explicitly set the :entire_image option to true.
      # However, that is not recommended because the blobs can be huge.
      #
      # Unlike other methods, this method returns a raw response object rather
      # than a wrapper model. Get the information you need using:
      #
      # * response.body    - blob data.
      # * response.headers - blob metadata.
      #
      # Example:
      #
      #   ret = @storage_acct.get_blob(@container, @blob, key, :start_byte => start_byte, :length => length)
      #   content_md5  = ret.headers[:content_md5].unpack("m0").first.unpack("H*").first
      #   returned_md5 = Digest::MD5.hexdigest(ret.body)
      #   raise "Checksum error: #{range_str}, blob: #{@container}/#{@blob}" unless content_md5 == returned_md5
      #   return ret.body
      #
      def get_blob_raw(container, blob, key = nil, options = {})
        key ||= properties.key1

        url = File.join(properties.primary_endpoints.blob, container, blob)
        url += "?snapshot=" + options[:date] if options[:date]

        additional_headers = {
          'verb' => 'GET'
        }

        range_str = nil
        if options[:range]
          range_str = "bytes=#{options[:range].min}-#{options[:range].max}"
        elsif options[:start_byte]
          range_str = "bytes=#{options[:start_byte]}-"
          if options[:end_byte]
            range_str << options[:end_byte].to_s
          elsif options[:length]
            range_str << (options[:start_byte] + options[:length] - 1).to_s
          end
        end

        if range_str
          additional_headers['x-ms-range'] = range_str
          additional_headers['x-ms-range-get-content-md5'] = true if options[:md5]
        else
          raise ArgumentError, "must specify byte range or entire_image flag" unless options[:entire_image]
        end

        headers = build_headers(url, key, :blob, additional_headers)

        ArmrestService.send(
          :rest_get,
          :url         => url,
          :headers     => headers,
          :proxy       => proxy,
          :ssl_version => ssl_version,
          :ssl_verify  => ssl_verify,
        )
      end

      private

      # Build a query string from a hash of options.
      #
      def build_query(options)
        array = []

        options.each do |key, value|
          next if key == :all
          if [:filter, :select, :top].include?(key)
            array << "$#{key}=#{value}" if value
          elsif key == :continuation_token
            value.each { |k, token| array << "#{k}=#{token}" if token }
          else
            array << "#{key}=#{value}" if value
          end
        end

        array.join('&')
      end

      # Get the continuation tokens from the response headers for paging results.
      #
      def parse_continuation_tokens(response)
        headers = response.headers

        token = {
          :NextPartitionKey => headers[:x_ms_continuation_nextpartitionkey],
          :NextRowKey       => headers[:x_ms_continuation_nextrowkey],
          :NextTableName    => headers[:x_ms_continuation_nexttablename]
        }

        # If there are no continuation values at all, then return nil
        token = nil if token.all? { |_key, value| value.nil? }

        token
      end

      # Using the blob primary endpoint as a base, join any arguments to the
      # the url and submit an http request.
      #
      def blob_response(key, query, *args)
        url = File.join(properties.primary_endpoints.blob, *args) + "?#{query}"
        headers = build_headers(url, key, 'blob')

        ArmrestService.send(
          :rest_get,
          :url         => url,
          :headers     => headers,
          :proxy       => proxy,
          :ssl_version => ssl_version,
          :ssl_verify  => ssl_verify,
        )
      end

      # Using the blob primary endpoint as a base, join any arguments to the
      # the url and submit an http request.
      def table_response(key, query = nil, *args)
        url = File.join(properties.primary_endpoints.table, *args)

        headers = build_headers(url, key, 'table')
        headers['Accept'] = 'application/json;odata=fullmetadata'

        # Must happen after headers are built
        unless query.nil? || query.empty?
          url << "?#{query}"
        end

        ArmrestService.send(
          :rest_get,
          :url         => url,
          :headers     => headers,
          :proxy       => proxy,
          :ssl_version => ssl_version,
          :ssl_verify  => ssl_verify,
        )
      end

      # Set the headers needed, including the Authorization header.
      #
      def build_headers(url, key, sig_type = nil, additional_headers = {})
        sig = Signature.new(url, key)
        sig_type ||= 'blob'

        # RestClient will set the Content-Type to application/x-www-form-urlencoded.
        # We must override this setting or the request will fail in some cases.

        headers = {
          'Content-Type'  => '',
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
