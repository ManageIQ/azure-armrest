# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Base class for managing virtual machine images
    class VirtualMachineImageService < ArmrestService
      # The location used in requests when gathering VM image information.
      attr_accessor :location

      # The publisher used in requests when gathering VM image information.
      attr_accessor :publisher

      # Create and return a new VirtualMachineImageService instance.
      #
      # This subclass accepts the additional :location, :provider, and
      # :publisher options as well.
      #
      def initialize(configuration, options = {})
        super(configuration, 'locations/publishers', 'Microsoft.Compute', options)

        @location  = options[:location]
        @publisher = options[:publisher]
      end

      # Return information about a specific offer/sku/version for the given
      # +publisher+ within +location+.
      #
      def get(offer, sku, version, location = @location, publisher = @publisher)
        check_for_location_and_publisher(location, publisher)

        url = build_url(
          location, 'publishers', publisher, 'artifacttypes',
          'vmimage', 'offers', offer, 'skus', sku, 'versions', version
        )

        response = rest_get(url)
        Azure::Armrest::VirtualMachineImage.new(response)
      end

      # Return a list of all VM image offers from the given +location+.
      #
      # Example:
      #
      #   vmis.list_all('eastus')
      #
      def list_all(location = @location)
        raise ArgumentError, "No location specified" unless location

        mutex  = Mutex.new
        images = []
        max    = configuration.max_threads

        Parallel.each(publishers(location), :in_threads => max) do |publisher|
          Parallel.each(offers(location, publisher.name), :in_threads => max) do |offer|
            Parallel.each(skus(offer.name, location, publisher.name), :in_threads => max) do |sku|
              Parallel.each(versions(sku.name, offer.name, location, publisher.name), :in_threads => max) do |version|
                mutex.synchronize do
                  images << Azure::Armrest::VirtualMachineImage.new(
                    :location  => version.location,
                    :publisher => publisher.name,
                    :offer     => offer.name,
                    :sku       => sku.name,
                    :version   => version.name,
                    :id        => "#{publisher.name}:#{offer.name}:#{sku.name}:#{version.name}"
                  )
                end
              end
            end
          end
        end

        images
      end

      # Return a list of VM image offers from the given +publisher+ and +location+.
      #
      # Example:
      #
      #   vmis.offers('eastus', 'Canonical')
      #
      def offers(location = @location, publisher = @publisher)
        check_for_location_and_publisher(location, publisher)

        url = build_url(location, 'publishers', publisher, 'artifacttypes', 'vmimage', 'offers')

        JSON.parse(rest_get(url)).map { |hash| Azure::Armrest::Offer.new(hash) }
      end

      # Return a list of VM image publishers for the given +location+.
      #
      # Example:
      #
      #   vmis.publishers('eastus')
      #
      def publishers(location = @location)
        raise ArgumentError, "No location specified" unless location

        url = build_url(location, 'publishers')

        JSON.parse(rest_get(url)).map { |hash| Azure::Armrest::Publisher.new(hash) }
      end

      # Return a list of VM image skus for the given +offer+, +location+,
      # and +publisher+.
      #
      # Example:
      #
      #   vmis.skus('UbuntuServer', 'eastus', 'Canonical')
      #
      def skus(offer, location = @location, publisher = @publisher)
        check_for_location_and_publisher(location, publisher)

        url = build_url(
          location, 'publishers', publisher, 'artifacttypes',
          'vmimage', 'offers', offer, 'skus'
        )

        JSON.parse(rest_get(url)).map { |hash| Azure::Armrest::Sku.new(hash) }
      end

      # Return a list of VM image versions for the given +sku+, +offer+,
      # +location+ and +publisher+.
      #
      # Example:
      #
      #   vmis.versions('15.10', 'UbuntuServer', 'eastus', 'Canonical').map(&:name)
      #
      #   # sample output
      #   => ["15.10.201511111", "15.10.201511161", "15.10.201512030"]
      #
      def versions(sku, offer, location = @location, publisher = @publisher)
        check_for_location_and_publisher(location, publisher)

        url = build_url(
          location, 'publishers', publisher, 'artifacttypes',
          'vmimage', 'offers', offer, 'skus', sku, 'versions'
        )

        JSON.parse(rest_get(url)).map { |hash| Azure::Armrest::ImageVersion.new(hash) }
      end

      # Retrieve information about a specific extension image for +type+ and +version+.
      #
      # Example:
      #
      #   vmis.extension('LinuxDiagnostic', '2.3.9029', 'westus2', 'Microsoft.OSTCExtensions')
      #
      def extension(type, version, location = @location, publisher = @publisher)
        check_for_location_and_publisher(location, publisher)

        url = build_url(
          location, 'publishers', publisher, 'artifacttypes',
          'vmextension', 'types', type, 'versions', version
        )

        response = rest_get(url)
        Azure::Armrest::ExtensionType.new(response)
      end

      # Return a list of extension types for the given +location+ and +publisher+.
      #
      # Example:
      #
      #   vmis.extension_types('westus', 'Microsoft.OSTCExtensions')
      #
      def extension_types(location = @location, publisher = @publisher)
        check_for_location_and_publisher(location, publisher)

        url = build_url(location, 'publishers', publisher, 'artifacttypes', 'vmextension', 'types')

        response = rest_get(url)
        JSON.parse(response).map { |hash| Azure::Armrest::ExtensionType.new(hash) }
      end

      # Return a list of versions for the given +type+ in the provided +location+
      # and +publisher+.
      #
      # Example:
      #
      #   vmis.extension_type_versions('LinuxDiagnostic', 'eastus', 'Microsoft.OSTCExtensions')
      #
      def extension_type_versions(type, location = @location, publisher = @publisher)
        check_for_location_and_publisher(location, publisher)

        url = build_url(location, 'publishers', publisher, 'artifacttypes', 'vmextension', 'types', type, 'versions')

        response = rest_get(url)
        JSON.parse(response).map { |hash| Azure::Armrest::ExtensionType.new(hash) }
      end

      private

      # Raise an error if either the +location+ or +publisher+ are nil. Used
      # by other methods to handle explicit nils.
      #
      def check_for_location_and_publisher(location, publisher)
        raise ArgumentError, "No location specified" unless location
        raise ArgumentError, "No publisher specified" unless publisher
      end

      # Builds a URL based on subscription_id an resource_group and any other
      # arguments provided, and appends it with the api_version.
      #
      def build_url(location, *args)
        url = File.join(base_url, 'providers', provider, 'locations', location)
        url = File.join(url, *args) unless args.empty?
        url << "?api-version=#{@api_version}"
      end
    end # VirtualMachineImageService
  end # Armrest
end # Azure
