module ENet
  class Client
    Address = Struct.new(:host, :port)

    attr_reader :_peer, :id, :address

    def self.enet_host_address_to_ipv4(address)
      str_ptr = FFI::MemoryPointer.new(:char, 256)
      result = LibENet.enet_address_get_host_ip(address, str_ptr, str_ptr.size)
      raise "Failed to get IPv4 address of enet address" unless result.zero?

      str_ptr.read_string
    end

    def initialize(peer)
      @_peer = peer

      @id = @_peer[:connect_id]
      @address = Address.new(Client.enet_host_address_to_ipv4(@_peer[:address]), @_peer[:address][:port])
    end

    def last_send_time
      @_peer[:last_send_time]
    end

    def last_receive_time
      @_peer[:last_receive_time]
    end

    def packets_sent
      @_peer[:packets_sent]
    end

    def data_sent
      @_peer[:incoming_data_total]
    end

    def packets_received # FIXME: This might not be compariable to #packets_sent
      @_peer[:host][:total_received_packets]
    end

    def data_received
      @_peer[:outgoing_data_total]
    end

    def packets_lost
      @_peer[:packets_lost]
    end

    def packet_loss
      @_peer[:packet_loss]#.to_f / LibENet::ENET_PEER_PACKET_LOSS_SCALE
    end

    def last_round_trip_time
      @_peer[:last_round_trip_time]
    end

    def round_trip_time
      @_peer[:round_trip_time]
    end
  end
end
