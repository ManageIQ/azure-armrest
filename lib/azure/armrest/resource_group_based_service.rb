module Azure::Armrest
  # Base class for services that needs to run in a resource group
  class ResourceGroupBasedService < ArmrestService
    def create(name, rgroup = armrest_configuration.resource_group, options = {})
      raise ArgumentError, "must specify resource group" unless rgroup
      raise ArgumentError, "must specify name of the resource" unless name

      url = build_url(rgroup, name)
      url = yield(url) || url if block_given?
      response = rest_put(build_url(rgroup, name), options.to_json)
      model_class.new(response) unless response.empty?
    end

    alias update create

    def list(rgroup = armrest_configuration.resource_group)
      raise ArgumentError, "must specify resource group" unless rgroup

      url = build_url(rgroup)
      url = yield(url) || url if block_given?
      response = rest_get(url)
      JSON.parse(response)['value'].map{ |hash| model_class.new(hash) }
    end

    def list_all
      url = build_url
      url = yield(url) || url if block_given?
      response = rest_get(url)
      JSON.parse(response)['value'].map{ |hash| model_class.new(hash) }
    end

    def get(name, rgroup = armrest_configuration.resource_group)
      raise ArgumentError, "must specify resource group" unless rgroup
      raise ArgumentError, "must specify name of the resource" unless name

      url = build_url(rgroup, name)
      url = yield(url) || url if block_given?
      response = rest_get(url)
      model_class.new(response)
    end

    def delete(name, rgroup= armrest_configuration.resource_group)
      raise ArgumentError, "must specify resource group" unless rgroup
      raise ArgumentError, "must specify name of the resource" unless name

      url = build_url(rgroup, name)
      url = yield(url) || url if block_given?
      rest_delete(url)
      nil
    end

    private

    # Builds a URL based on subscription_id an resource_group and any other
    # arguments provided, and appends it with the api_version.
    #
    def build_url(resource_group = nil, *args)
      url = File.join(Azure::Armrest::COMMON_URI, armrest_configuration.subscription_id)
      url = File.join(url, 'resourceGroups', resource_group) if resource_group
      url = File.join(url, 'providers', @provider, @service_name)
      url = File.join(url, *args) unless args.empty?
      url << "?api-version=#{@api_version}"
    end

    def model_class
      @model_class ||= Object.const_get(self.class.to_s.sub(/Service$/, ''))
    end

    # Aggregate resources from each group
    # To be used in the case that API does not support list_all with one call
    def list_in_all_groups
      array = []
      threads = []
      mutex = Mutex.new

      resource_groups.each do |rg|
        threads << Thread.new(rg['name']) do |group|
          url = build_url(group)
          response = rest_get(url)

          results = JSON.parse(response)['value'].map { |hash| model_class.new(hash) }

          if results && !results.empty?
            mutex.synchronize{ array << results }
          end
        end
      end

      threads.each(&:join)

      array.flatten
    end
  end
end
