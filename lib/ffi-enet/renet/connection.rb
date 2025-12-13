module ENet
  class Connection
    attr_reader :client

    def initialize(host:, port:, channels: 8, download_bandwidth: 0, upload_bandwidth: 0)
      @host = host
      @port = port
      @channels = channels
      @download_bandwidth = download_bandwidth
      @upload_bandwidth = upload_bandwidth

      @enet_event = LibENet::ENetEvent.new
      @online = false

      ENet.init

      @_address = LibENet::ENetAddress.new
      if LibENet.enet_address_set_host(@_address, @host) != 0
        raise "Failed to set host"
      end
      @_address[:port] = @port

      @_host = LibENet.enet_host_create(nil, 1, @channels, @download_bandwidth, @upload_bandwidth)

      raise "Failed to create host" if @_host.nil?

      @client = nil
    end

    def online?
      @online
    end

    def connected?
      online?
    end

    def connect(timeout_ms)
      @_connection = LibENet.enet_host_connect(@_host, @_address, @channels, 0)
      raise "Cannot connect to remote host" if @_connection.nil?
    end

    def disconnect(timeout_ms)
      connected = online?

      if connected
        LibENet.enet_peer_disconnect(@_connection, 0)

        while (result = LibENet.enet_host_service(@_host, @enet_event, 0)) && result.positive?

          case @enet_event[:type]
          when :ENET_EVENT_TYPE_RECEIVE
            LibENet.enet_packet_destroy(@enet_event[:packet])

          when :ENET_EVENT_TYPE_DISCONNECT
            connected = false
          end

          break unless connected
        end

        LibENet.enet_peer_disconnect_now(@_connection, 0) if connected
      end

      connected
    end

    def send_packet(data, reliable:, channel:)
      return unless online?

      packet = LibENet.enet_packet_create(data, data.length, reliable ? 1 : 0)
      LibENet.enet_peer_send(@_connection, channel, packet)
    end

    def send_queued_packets
      LibENet.enet_host_flush(@_host) if online?
    end

    def flush
      send_queued_packets
    end

    def update(timeout_ms)
      result = LibENet.enet_host_service(@_host, @enet_event, timeout_ms)

      if result.positive?
        case @enet_event[:type]
        when :ENET_EVENT_TYPE_CONNECT
          @online = true
          @client = Client.new(@_connection)

          on_connection
        when :ENET_EVENT_TYPE_RECEIVE
          data = @enet_event[:packet][:data].read_string(@enet_event[:packet][:length])

          @client.update_stats
          on_packet_received(data, @enet_event[:channel_id])

          LibENet.enet_packet_destroy(@enet_event[:packet])

        when :ENET_EVENT_TYPE_DISCONNECT
          @online = false
        end
      elsif result.negative?
        warn "Connection: An error occurred: #{result}"
      end

      result
    end

    def use_compression(bool)
      if bool
        LibENet.enet_host_compress_with_range_coder(@_host)
      else
        LibENet.enet_host_compress(@_host, nil)
      end
    end

    def on_connection
    end

    def on_packet_received(data, channel)
    end

    def on_disconnection
    end
  end
end
