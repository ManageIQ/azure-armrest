require 'rest-client'
require 'json'
require 'thread'
require 'addressable'
require 'parallel'
require 'cache_method'

# The Azure module serves as a namespace.
module Azure
  # The Armrest module mostly serves as a namespace, but also contains any
  # common constants shared by subclasses.
  module Armrest
  end
end

require 'azure/armrest/version'
require 'azure/armrest/configuration'
require 'azure/armrest/environment'
require 'azure/armrest/exception'
require 'azure/armrest/armrest_service'
require 'azure/armrest/active_directory'
require 'azure/armrest/active_directory/configuration'
require 'azure/armrest/active_directory/user_service'
require 'azure/armrest/active_directory/group_service'
require 'azure/armrest/armrest_collection'
require 'azure/armrest/subscription_service'
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
require 'azure/armrest/insights/diagnostic_service'
require 'azure/armrest/insights/event_service'
require 'azure/armrest/insights/metrics_service'
require 'azure/armrest/network/load_balancer_service'
require 'azure/armrest/network/inbound_nat_service'
require 'azure/armrest/network/ip_address_service'
require 'azure/armrest/network/network_interface_service'
require 'azure/armrest/network/network_security_group_service'
require 'azure/armrest/network/network_security_rule_service'
require 'azure/armrest/network/route_table_service'
require 'azure/armrest/network/route_service'
require 'azure/armrest/network/virtual_network_service'
require 'azure/armrest/network/subnet_service'
require 'azure/armrest/role/assignment_service'
require 'azure/armrest/role/definition_service'
require 'azure/armrest/sql/sql_server_service'
require 'azure/armrest/sql/sql_database_service'
require 'azure/armrest/billing/usage_service'

# JSON wrapper classes. The service classes should require their own
# wrappers from this point on.
require_relative 'armrest/model/base_model'
