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
require 'azure/armrest/exception'
require 'azure/armrest/armrest_service'
require 'azure/armrest/resource_group_based_service'
require 'azure/armrest/resource_group_based_subservice'
require 'azure/armrest/storage_account_service'
require 'azure/armrest/availability_set_service'
require 'azure/armrest/virtual_machine_service'
require 'azure/armrest/virtual_machine_image_service'
require 'azure/armrest/virtual_machine_extension_service'
require 'azure/armrest/template_deployment_service'
require 'azure/armrest/resource_service'
require 'azure/armrest/resource_group_service'
require 'azure/armrest/resource_provider_service'
require 'azure/armrest/insights/alert_service'
require 'azure/armrest/insights/event_service'
require 'azure/armrest/network/ip_address_service'
require 'azure/armrest/network/network_interface_service'
require 'azure/armrest/network/network_security_group_service'
require 'azure/armrest/network/network_security_rule_service'
require 'azure/armrest/network/virtual_network_service'
require 'azure/armrest/network/subnet_service'
require 'azure/armrest/role/assignment_service'
require 'azure/armrest/role/definition_service'
require 'azure/armrest/sql/sql_server_service'
require 'azure/armrest/sql/sql_database_service'

# JSON wrapper classes. The service classes should require their own
# wrappers from this point on.
require_relative 'armrest/model/base_model'
require_relative 'armrest/model/virtual_machine'
require_relative 'armrest/model/virtual_machine_model'
require_relative 'armrest/model/virtual_machine_instance'
require_relative 'armrest/model/data_disk'
require_relative 'armrest/model/os_disk'
