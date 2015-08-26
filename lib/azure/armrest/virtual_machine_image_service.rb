# Azure namespace
module Azure
  # Armrest namespace
  module Armrest
    # Base class for managing virtual machine images
    class VirtualMachineImageService < ArmrestService
      # The location used in requests when gathering VM image information.
      attr_accessor :location

      # The provider used in requests when gathering VM image information.
      attr_reader :provider

      # The publisher used in requests when gathering VM image information.
      attr_accessor :publisher

      # Create and return a new VirtualMachineImageService (VMIM) instance.
      #
      # This subclass accepts the additional :location, :provider, and
      # :publisher options as well. The default provider is set to
      # 'Microsoft.Compute'.
      #
      def initialize(_armrest_configuration, options = {})
        super

        @location  = options[:location]
        @provider  = options[:provider] || 'Microsoft.Compute'
        @publisher = options[:publisher]

        set_service_api_version(options, 'locations/publishers')
      end

      # Set a new provider to use the default for other methods. This may alter
      # the api_version used for future requests. In practice, only
      # 'Microsoft.Compute' or 'Microsoft.ClassicCompute' should be used.
      #
      def provider=(name)
        @provider = name
        set_service_api_version({}, 'locations/publishers')
      end

      # Return a list of VM image offers from the given +publisher+ and +location+.
      #
      # Example:
      #
      #   vmim.offers('eastus', 'Canonical')
      #
      def offers(location = @location, publisher = @publisher)
        raise ArgumentError, "No location specified" unless location
        raise ArgumentError, "No publisher specified" unless publisher

        url = build_url(location, 'publishers', publisher, 'artifacttypes', 'vmimage', 'offers')

        JSON.parse(rest_get(url)).map{ |element| element['name'] }
      end

      # Return a list of VM image publishers for the given +location+.
      #
      # Example:
      #
      #   vmim.publishers('eastus')
      #
      def publishers(location = @location)
        raise ArgumentError, "No location specified" unless location

        url = build_url(location, 'publishers')

        JSON.parse(rest_get(url)).map{ |element| element['name'] }
      end

      # Return a list of VM image skus for the given +offer+, +location+,
      # and +publisher+.
      #
      # Example:
      #
      #   vmim.skus('UbuntuServer', 'eastus', 'Canonical')
      #
      def skus(offer, location = @location, publisher = @publisher)
        raise ArgumentError, "No location specified" unless location
        raise ArgumentError, "No publisher specified" unless publisher

        url = build_url(
          location, 'publishers', publisher, 'artifacttypes',
          'vmimage', 'offers', offer, 'skus'
        )

        JSON.parse(rest_get(url)).map{ |element| element['name'] }
      end

      # Return a list of VM image versions for the given +sku+, +offer+,
      # +location+ and +publisher+.
      #
      # Example:
      #
      #   vmim.versions('14.04.2', 'UbuntuServer', 'eastus', 'Canonical')
      #
      #   # sample output
      #   => ["14.04.201503090", "14.04.201505060", "14.04.201506100", "14.04.201507060"]
      #
      def versions(sku, offer, location = @location, publisher = @publisher)
        raise ArgumentError, "No location specified" unless location
        raise ArgumentError, "No publisher specified" unless publisher

        url = build_url(
          location, 'publishers', publisher, 'artifacttypes', 'vmimage',
          'offers', offer, 'skus', sku, 'versions'
        )

        JSON.parse(rest_get(url)).map{ |element| element['name'] }
      end

      private

      # Builds a URL based on subscription_id an resource_group and any other
      # arguments provided, and appends it with the api_version.
      #
      def build_url(location, *args)
        url = File.join(
          Azure::Armrest::COMMON_URI,
          armrest_configuration.subscription_id,
          'providers',
          provider,
          'locations',
          location
        )

        url = File.join(url, *args) unless args.empty?
        url << "?api-version=#{api_version}"
      end

    end # VirtualMachineImageService
  end # Armrest
end # Azure
