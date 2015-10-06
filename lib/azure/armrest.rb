require 'rest-client'
require 'json'
require 'thread'
require 'uri'

# The Azure module serves as a namespace.
module Azure

  # The Armrest module mostly serves as a namespace, but also contains any
  # common constants shared by subclasses.
  module Armrest
    # The default Azure resource
    RESOURCE = "https://management.azure.com/"

    # The default authority resource
    AUTHORITY = "https://login.windows.net/"

    # A common URI for all subclasses
    COMMON_URI = RESOURCE + "subscriptions/"
  end

end

require 'azure/armrest/version'
require 'azure/armrest/armrest_service'
require 'azure/armrest/storage_account_service'
require 'azure/armrest/availability_set_service'
require 'azure/armrest/virtual_machine_service'
require 'azure/armrest/virtual_machine_image_service'
require 'azure/armrest/virtual_machine_extension_service'
require 'azure/armrest/event_service'
require 'azure/armrest/template_deployment_service'
require 'azure/armrest/resource_service'
require 'azure/armrest/resource_group_service'
require 'azure/armrest/resource_provider_service'
require 'azure/armrest/network/ip_address_service'
require 'azure/armrest/network/network_interface_service'
require 'azure/armrest/network/network_security_group_service'
require 'azure/armrest/network/virtual_network_service'
require 'azure/armrest/network/subnet_service'

# JSON wrapper classes. The service classes should require their own
# wrappers from this point on.
require_relative 'armrest/model/base_model'
