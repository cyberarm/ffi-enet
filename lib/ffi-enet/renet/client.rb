module ENet
  class Client
    Address = Struct.new(:host, :port)

    attr_reader :_peer, :id, :address
    attr_reader :last_send_time, :last_receive_time, :last_round_trip_time, :round_trip_time, :packets_lost, :packet_loss,
                :total_sent_packets, :total_sent_data, :total_received_packets, :total_received_data

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

      @last_send_time = 0
      @last_receive_time = 0
      @last_round_trip_time = 0
      @round_trip_time = 0
      @packets_lost = 0
      @packet_loss = 0

      @total_sent_packets = 0
      @total_sent_data = 0
      @total_received_packets = 0
      @total_received_data = 0

      update_stats
    end

    def update_stats
      # enet Peer data
      @last_send_time = @_peer[:last_send_time]
      @last_receive_time = @_peer[:last_send_time]
      @last_round_trip_time = @_peer[:last_round_trip_time]
      @round_trip_time = @_peer[:round_trip_time]
      @packets_lost = @_peer[:packets_lost]
      @packet_loss = @_peer[:packet_loss] # .to_f / LibENet::ENET_PEER_PACKET_LOSS_SCALE

      # enet Host data
      @total_sent_packets = @_peer[:host][:total_sent_packets]
      @total_sent_data = @_peer[:host][:total_sent_data]
      @total_received_packets = @_peer[:host][:total_received_packets]
      @total_received_data = @_peer[:host][:total_received_data]
    end
  end
end
