require 'rest-client'
require 'json'

# The Azure module serves as a namespace.
module Azure

  # The ArmRest module mostly serves as a namespace, but also contains any
  # common constants shared by subclasses.
  module ArmRest
    # The default Azure resource
    RESOURCE = "https://management.azure.com"

    # The default authority resource
    AUTHORITY = "https://login.windows.net"

    # A common URI for all subclasses
    COMMON_URI = RESOURCE + "/subscriptions"
  end

end

require_relative 'armrest/armrest_manager'
require_relative 'armrest/storage_account_manager'
require_relative 'armrest/availability_set_manager'
require_relative 'armrest/virtual_machine_manager'
require_relative 'armrest/virtual_machine_extension_manager'
require_relative 'armrest/virtual_network_manager'
require_relative 'armrest/subnet_manager'
require_relative 'armrest/event_manager'
