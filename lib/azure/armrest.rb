require 'rest-client'
require 'json'
require 'thread'

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
require 'azure/armrest/virtual_network_service'
require 'azure/armrest/subnet_service'
require 'azure/armrest/event_service'
require 'azure/armrest/template_deployment_service'
