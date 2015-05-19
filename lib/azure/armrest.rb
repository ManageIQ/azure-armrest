require 'rest-client'
require 'json'

# The Azure module serves as a namespace.
module Azure

  # The ArmRest module most serves as a namespace, but also contains any
  # common constants shared by subclasses.
  module ArmRest
    # Base URI used by all subclasses
    COMMON_URI = "https://management.azure.com/subscriptions"
  end

end

require_relative 'armrest/armrest_manager'
require_relative 'armrest/storage_account_manager'
require_relative 'armrest/virtual_machine_manager'
require_relative 'armrest/event_manager'
