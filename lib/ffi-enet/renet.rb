require_relative "renet/server"
require_relative "renet/connection"
require_relative "renet/client"

module ENet
  @@initialized = false
  @@at_exit_handler = false

  def self.init
    return true if @@initialized

    return false if LibENet.enet_initialize != 0

    @@initialized = true

    unless @@at_exit_handler
      @@at_exit_handler = true

      at_exit do
        shutdown
      end
    end

    true
  end

  def self.shutdown
    return unless @@initialized

    LibENet.enet_deinitialize

    @@initialized = false
  end
end
