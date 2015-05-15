require 'rest-client'
require 'json'

module Azure
  module ArmRest
    COMMON_URI = "https://management.azure.com/subscriptions"
  end
end

require_relative 'armrest/armrest_manager'
require_relative 'armrest/virtual_machine_manager'
require_relative 'armrest/event_manager'
