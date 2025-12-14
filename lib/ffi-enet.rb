require "ffi"
require_relative "ffi-enet/version"

module LibENet
  extend FFI::Library
  ffi_lib [
    "#{File.expand_path(__dir__)}#{RUBY_PLATFORM.match?(/^x86_64-/) ? "/../lib64" : ""}/libenet.so",
    "#{File.expand_path(__dir__)}#{RUBY_PLATFORM.match?(/^x64-/) ? "/../lib64" : ""}/libenet.dll",
    "enet"
  ]

  # "Constants"
  ENET_PROTOCOL_MINIMUM_MTU = 576
  ENET_PROTOCOL_MAXIMUM_MTU = 4096
  ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS = 32
  ENET_PROTOCOL_MINIMUM_WINDOW_SIZE = 4096
  ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE = 65536
  ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT = 1
  ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT = 255
  ENET_PROTOCOL_MAXIMUM_PEER_ID = 0xFFF
  ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT = 1024 * 1024

  ENET_BUFFER_MAXIMUM = (1 + 2 * ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS)

  ENET_HOST_RECEIVE_BUFFER_SIZE = 256 * 1024,
  ENET_HOST_SEND_BUFFER_SIZE = 256 * 1024,
  ENET_HOST_BANDWIDTH_THROTTLE_INTERVAL = 1000,
  ENET_HOST_DEFAULT_MTU = 1392,
  ENET_HOST_DEFAULT_MAXIMUM_PACKET_SIZE = 32 * 1024 * 1024,
  ENET_HOST_DEFAULT_MAXIMUM_WAITING_DATA = 32 * 1024 * 1024,

  ENET_PEER_DEFAULT_ROUND_TRIP_TIME = 500,
  ENET_PEER_DEFAULT_PACKET_THROTTLE = 32,
  ENET_PEER_PACKET_THROTTLE_SCALE = 32,
  ENET_PEER_PACKET_THROTTLE_COUNTER = 7,
  ENET_PEER_PACKET_THROTTLE_ACCELERATION = 2,
  ENET_PEER_PACKET_THROTTLE_DECELERATION = 2,
  ENET_PEER_PACKET_THROTTLE_INTERVAL = 5000,
  ENET_PEER_PACKET_LOSS_SCALE = (1 << 16),
  ENET_PEER_PACKET_LOSS_INTERVAL = 10000,
  ENET_PEER_WINDOW_SIZE_SCALE = 64 * 1024,
  ENET_PEER_TIMEOUT_LIMIT = 32,
  ENET_PEER_TIMEOUT_MINIMUM = 5000,
  ENET_PEER_TIMEOUT_MAXIMUM = 30000,
  ENET_PEER_PING_INTERVAL = 500,
  ENET_PEER_UNSEQUENCED_WINDOWS = 64,
  ENET_PEER_UNSEQUENCED_WINDOW_SIZE = 1024,
  ENET_PEER_FREE_UNSEQUENCED_WINDOWS = 32,
  ENET_PEER_RELIABLE_WINDOWS = 16,
  ENET_PEER_RELIABLE_WINDOW_SIZE = 0x1000,
  ENET_PEER_FREE_RELIABLE_WINDOWS = 8

  # Enums
  ENetEventType = enum(
    :ENET_EVENT_TYPE_NONE,
    :ENET_EVENT_TYPE_CONNECT,
    :ENET_EVENT_TYPE_DISCONNECT,
    :ENET_EVENT_TYPE_RECEIVE
  )

  ENetPeerState = enum(
    :ENET_PEER_STATE_DISCONNECTED,
    :ENET_PEER_STATE_CONNECTING,
    :ENET_PEER_STATE_ACKNOWLEDGING_CONNECT,
    :ENET_PEER_STATE_CONNECTION_PENDING,
    :ENET_PEER_STATE_CONNECTION_SUCCEEDED,
    :ENET_PEER_STATE_CONNECTED,
    :ENET_PEER_STATE_DISCONNECT_LATER,
    :ENET_PEER_STATE_DISCONNECTING,
    :ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT,
    :ENET_PEER_STATE_ZOMBIE
  )

  ENetSocketOption = enum(
    :ENET_SOCKOPT_NONBLOCK, 1,
    :ENET_SOCKOPT_BROADCAST,
    :ENET_SOCKOPT_RCVBUF,
    :ENET_SOCKOPT_SNDBUF,
    :ENET_SOCKOPT_REUSEADDR,
    :ENET_SOCKOPT_RCVTIMEO,
    :ENET_SOCKOPT_SNDTIMEO,
    :ENET_SOCKOPT_ERROR,
    :ENET_SOCKOPT_NODELAY,
    :ENET_SOCKOPT_TTL
  )

  ENetSocketShutdown = enum(
    :ENET_SOCKET_SHUTDOWN_READ,
    :ENET_SOCKET_SHUTDOWN_WRITE,
    :ENET_SOCKET_SHUTDOWN_READ_WRITE
  )

  ENetSocketType = enum(
    :ENET_SOCKET_TYPE_STREAM, 1,
    :ENET_SOCKET_TYPE_DATAGRAM
  )

  ENetPacketFlag = enum(
     :ENET_PACKET_FLAG_RELIABLE, (1 << 0),
     :ENET_PACKET_FLAG_UNSEQUENCED, (1 << 1),
     :ENET_PACKET_FLAG_NO_ALLOCATE, (1 << 2),
     :ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT, (1 << 3),
     :ENET_PACKET_FLAG_SENT, (1<<8)
)

  # Structs
  class ENetAddress < FFI::Struct
    layout(
      :host, :uint32,
      :port, :uint16
    )
  end

  class ENetPacket < FFI::Struct
    layout(
      :_ref_count, :size_t,
      :flags, :uint32,
      :data, :pointer,
      :length, :size_t,
      :callback, :pointer,
      :user_data, :pointer
    )
  end

  # Why on earth would you do this? They're the same types...
  if FFI::Platform.windows?
    # Windows O_o
    class ENetBuffer < FFI::Struct
      layout(
        :length, :size_t,
        :data, :pointer
      )
    end
  else
    # Unix o_O
    class ENetBuffer < FFI::Struct
      layout(
        :data, :pointer,
        :length, :size_t
      )
    end
  end

  class ENetCompressor < FFI::Struct
    layout(
      :context, :pointer,
      :compress, :pointer, # FIXME: http://sauerbraten.org/enet/structENetCompressor.html
      :decompress, :pointer, # FIXME
      :destroy, :pointer  # FIXME
    )
  end

  class ENetListNode < FFI::Struct
    layout(
      :next, ENetListNode.by_ref,
      :previous, ENetListNode.by_ref
    )
  end

  class ENetList < FFI::Struct
    layout(:sentinel, ENetListNode)
  end

  class ENetProtocolHeader < FFI::Struct
    layout(
      :peer_id, :uint16,
      :sent_time, :uint16
    )
  end

  class ENetProtocolCommandHeader < FFI::Struct
    layout(
      :command, :uint8,
      :channel_id, :uint8,
      :reliable_sequence_number, :uint16
    )
  end

  class ENetProtocolAcknowledge < FFI::Struct
    layout(
      :header, ENetProtocolCommandHeader,
      :received_reliable_sequence_number, :uint16,
      :received_sent_time, :uint16
    )
  end

  class ENetProtocolConnect < FFI::Struct
    layout(
      :header, ENetProtocolCommandHeader,
      :outgoing_peer_id, :uint16,
      :incoming_session_id, :uint8,
      :outgoing_session_id, :uint8,
      :mtu, :uint32,
      :window_size, :uint32,
      :channel_count, :uint32,
      :incoming_bandwidth, :uint32,
      :outgoing_bandwidth, :uint32,
      :packet_throttle_interval, :uint32,
      :packet_throttle_acceleration, :uint32,
      :packet_throttle_deceleration, :uint32,
      :connectID, :uint32,
      :data, :uint32
    )
  end

  class ENetProtocolVerifyConnect < FFI::Struct
    layout(
      :header, ENetProtocolCommandHeader,
      :outgoing_peer_id, :uint16,
      :incoming_session_id, :uint8,
      :outgoing_session_id, :uint8,
      :mtu, :uint32,
      :window_size, :uint32,
      :channel_count, :uint32,
      :incoming_bandwidth, :uint32,
      :outgoing_bandwidth, :uint32,
      :packet_throttle_interval, :uint32,
      :packet_throttle_acceleration, :uint32,
      :packet_throttle_deceleration, :uint32,
      :connect_id, :uint32
    )
  end

  class ENetProtocolBandwidthLimit < FFI::Struct
    layout(
      :header, ENetProtocolCommandHeader,
      :incoming_bandwidth, :uint32,
      :outgoing_bandwidth, :uint32
    )
  end

  class ENetProtocolThrottleConfigure < FFI::Struct
    layout(
      :header, ENetProtocolCommandHeader,
      :packet_throttle_interval, :uint32,
      :packet_throttle_acceleration, :uint32,
      :packet_throttle_deceleration, :uint32
    )
  end

  class ENetProtocolDisconnect < FFI::Struct
    layout(
      :header, ENetProtocolCommandHeader,
      :data, :uint32
    )
  end

  class ENetProtocolPing < FFI::Struct
    layout(:header, ENetProtocolCommandHeader)
  end

  class ENetProtocolSendReliable < FFI::Struct
    layout(
      :header, ENetProtocolCommandHeader,
      :data_length, :uint16
    )
  end

  class ENetProtocolSendUnreliable < FFI::Struct
    layout(
      :header, ENetProtocolCommandHeader,
      :unreliable_sequence_number, :uint16,
      :data_length, :uint16
    )
  end

  class ENetProtocolSendUnsequenced < FFI::Struct
    layout(
      :header, ENetProtocolCommandHeader,
      :unsequenced_group, :uint16,
      :data_length, :uint16
    )
  end

  class ENetProtocolSendFragment < FFI::Struct
    layout(
      :header, ENetProtocolCommandHeader,
      :start_sequence_number, :uint16,
      :data_length, :uint16,
      :fragment_count, :uint32,
      :fragment_number, :uint32,
      :total_length, :uint32,
      :fragment_offset, :uint32
    )
  end

  class ENetProtocol < FFI::Union
    layout(
      :header, ENetProtocolCommandHeader,
      :acknowledge, ENetProtocolAcknowledge,
      :connect, ENetProtocolConnect,
      :verify_connect, ENetProtocolVerifyConnect,
      :disconnect, ENetProtocolDisconnect,
      :ping, ENetProtocolPing,
      :send_reliable, ENetProtocolSendReliable,
      :send_unreliable, ENetProtocolSendUnreliable,
      :send_unsequenced, ENetProtocolSendUnsequenced,
      :send_fragment, ENetProtocolSendFragment,
      :bandwidth_limit, ENetProtocolBandwidthLimit,
      :throttle_configure, ENetProtocolThrottleConfigure
    )
  end

  if FFI::Platform.windows?
    typedef(:uint64, :ENetSocket)
  else
    typedef(:int, :ENetSocket) # FIXME: Test this on Linux
  end

  class ENetChannel < FFI::Struct
    layout(
      :outgoing_reliable_sequence_number, :uint16,
      :outgoing_unreliable_sequence_number, :uint16,
      :used_reliable_windows, :uint16,
      :reliable_Windows, [:uint16, ENET_PEER_RELIABLE_WINDOWS],
      :incoming_reliable_sequence_number, :uint16,
      :incoming_unreliable_sequence_number, :uint16,
      :incoming_reliable_commands, ENetList,
      :incoming_unreliable_commands, ENetList
     )
  end

  class ENetHost < FFI::Struct
    layout(
      :socket, :ENetSocket,
      :address, ENetAddress,
      :incoming_bandwidth, :uint32,
      :outgoing_bandwidth, :uint32,
      :bandwidth_throttle_epoch, :uint32,
      :mtu, :uint32,
      :random_seed, :uint32,
      :recalculate_bandwidth_limits, :int,
      :peers, :pointer, # Array of ENetPeer
      :peer_count, :size_t,
      :channel_limit, :size_t,
      :service_time, :uint32,
      :dispatch_queue, ENetList,
      :total_queued, :uint32,
      :packet_size, :size_t,
      :header_flags, :uint16,
      :commands, [ENetProtocol, ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS],
      :command_count, :size_t,
      :buffers, [ENetBuffer, ENET_BUFFER_MAXIMUM],
      :buffer_count, :size_t,
      :checksum, :pointer, # ENetChecksumCallback
      :compressor, ENetCompressor,
      :packet_data, [:uint8, 2 * ENET_PROTOCOL_MAXIMUM_MTU], # NOTE: This may be wrong size/offset/length... using a 1d array here, instead of [2][ENET_PROTOCOL_MAXIMUM_MTU]; FFI docs don't seem to show how to do a multidimentional array.
      :received_address, ENetAddress,
      :received_data, :string,
      :received_data_length, :size_t,
      :total_sent_data, :uint32,
      :total_sent_packets, :uint32,
      :total_received_data, :uint32,
      :total_received_packets, :uint32,
      :intercept, :pointer, # ENetInterceptCallback
      :connected_peers, :size_t,
      :bandwidth_limited_peers, :size_t,
      :duplicate_peers, :size_t,
      :maximum_packet_size, :size_t,
      :maximum_waiting_data, :size_t
    )
  end

  class ENetPeer < FFI::Struct
    layout(
      :dispatchList, ENetListNode,
      :host, ENetHost.by_ref,
      :outgoing_peer_id, :uint16,
      :incoming_peer_id, :uint16,
      :connect_id, :uint32,
      :outgoing_session_id, :uint8,
      :incoming_session_id, :uint8,
      :address, ENetAddress,
      :data, :pointer,
      :state, ENetPeerState,
      :channels, :pointer, # array of ENetChannel
      :channel_count, :size_t,
      :incoming_bandwidth, :uint32,
      :outgoing_bandwidth, :uint32,
      :incoming_bandwidth_throttle_epoch, :uint32,
      :outgoing_bandwidth_throttle_epoch, :uint32,
      :incoming_data_total, :uint32,
      :outgoing_data_total, :uint32,
      :last_send_time, :uint32,
      :last_receive_time, :uint32,
      :next_timeout, :uint32,
      :earliest_timeout, :uint32,
      :packet_loss_epoch, :uint32,
      :packets_sent, :uint32,
      :packets_lost, :uint32,
      :packet_loss, :uint32, # mean packet loss of reliable packets as a ratio with respect to the constant ENET_PEER_PACKET_LOSS_SCALE
      :packet_loss_variance, :uint32,
      :packet_throttle, :uint32,
      :packet_throttle_limit, :uint32,
      :packet_throttle_counter, :uint32,
      :packet_throttle_epoch, :uint32,
      :packet_throttle_acceleration, :uint32,
      :packet_throttle_deceleration, :uint32,
      :packet_throttle_interval, :uint32,
      :ping_interval, :uint32,
      :timeout_limit, :uint32,
      :timeout_minimum, :uint32,
      :timeout_maximum, :uint32,
      :last_round_trip_time, :uint32,
      :lowest_round_trip_time, :uint32,
      :last_round_trip_time_variance, :uint32,
      :highest_round_trip_time_variance, :uint32,
      :round_trip_time, :uint32, # mean round trip time (RTT), in milliseconds, between sending a reliable packet and receiving its acknowledgement
      :round_trip_time_variance, :uint32,
      :mtu, :uint32,
      :window_size, :uint32,
      :reliable_data_in_transit, :uint32,
      :outgoing_reliable_sequence_number, :uint16,
      :acknowledgements, ENetList,
      :sent_reliable_commands, ENetList,
      :outgoing_send_reliable_commands, ENetList,
      :outgoing_commands, ENetList,
      :dispatched_commands, ENetList,
      :flags, :uint16,
      :reserved, :uint16,
      :incoming_unsequenced_group, :uint16,
      :outgoing_unsequenced_group, :uint16,
      :unsequenced_window, [:uint32, ENET_PEER_UNSEQUENCED_WINDOW_SIZE / 32],
      :event_data, :uint32,
      :total_waiting_data, :size_t
    )
  end

  class ENetEvent < FFI::Struct
    layout(
      :type, ENetEventType,
      :peer, ENetPeer.by_ref,
      :channel_id, :uint8,
      :data, :uint32,
      :packet, ENetPacket.by_ref
    )
  end

  # Global
  attach_function :enet_deinitialize, [], :void
  attach_function :enet_initialize, [], :int
  attach_function :enet_initialize_with_callbacks, [:uint32, :pointer], :int # FIXME
  attach_function :enet_linked_version, [], :uint

  # Address
  attach_function :enet_address_get_host, [ENetAddress.by_ref, :pointer, :size_t], :int
  attach_function :enet_address_get_host_ip, [ENetAddress.by_ref, :pointer, :size_t], :int
  attach_function :enet_address_set_host, [ENetAddress.by_ref, :string], :int
  attach_function :enet_address_set_host_ip, [ENetAddress.by_ref, :string], :int

  # Host
  attach_function :enet_host_bandwidth_limit, [ENetHost, :uint32, :uint32], :void
  attach_function :enet_host_broadcast, [ENetHost, :uint8, :pointer], :void
  attach_function :enet_host_channel_limit, [ENetHost, :size_t], :void
  attach_function :enet_host_check_events, [ENetHost, ENetEvent.by_ref], :int
  attach_function :enet_host_compress, [ENetHost, ENetCompressor.by_ref], :int
  attach_function :enet_host_compress_with_range_coder, [ENetHost], :int
  attach_function :enet_host_connect, [ENetHost, ENetAddress.by_ref, :size_t, :uint32], ENetPeer.by_ref
  attach_function :enet_host_create, [ENetAddress.by_ref, :size_t, :size_t, :uint32, :uint32], ENetHost
  attach_function :enet_host_destroy, [ENetHost], :void
  attach_function :enet_host_flush, [ENetHost], :void
  attach_function :enet_host_service, [ENetHost, ENetEvent.by_ref, :uint32], :int, blocking: true

  # Packet
  attach_function :enet_crc32, [:pointer, :size_t], :uint32
  attach_function :enet_packet_create, [:string, :size_t, :uint32], ENetPacket.by_ref
  attach_function :enet_packet_destroy, [ENetPacket.by_ref], :void
  attach_function :enet_packet_resize, [ENetHost, :size_t], :int

  # Peer
  attach_function :enet_peer_disconnect, [ENetPeer.by_ref, :uint32], :void
  attach_function :enet_peer_disconnect_later, [ENetPeer.by_ref, :uint32], :void
  attach_function :enet_peer_disconnect_now, [ENetPeer.by_ref, :uint32], :void
  attach_function :enet_peer_ping, [ENetPeer.by_ref], :void
  attach_function :enet_peer_ping_interval, [ENetPeer.by_ref, :uint32], :void
  attach_function :enet_peer_receive, [ENetPeer.by_ref, :uint8], ENetPacket.by_ref # FIXME
  attach_function :enet_peer_reset, [ENetPeer.by_ref], :void
  attach_function :enet_peer_send, [ENetPeer.by_ref, :uint16, ENetPacket.by_ref], :int
  attach_function :enet_peer_throttle_configure, [ENetPeer.by_ref, :uint32, :uint32, :uint32], :void
  attach_function :enet_peer_timeout, [ENetPeer.by_ref, :uint32, :uint32, :uint32], :void

  # Range Coder
  attach_function :enet_range_coder_compress, [:pointer, ENetBuffer.by_ref, :size_t, :size_t, :uint8, :size_t], :size_t
  attach_function :enet_range_coder_create, [], :pointer
  attach_function :enet_range_coder_decompress, [:pointer, :uint16, :size_t, :uint16, :size_t], :size_t
  attach_function :enet_range_coder_destroy, [:pointer], :void

  # Time
  attach_function :enet_time_get, [], :uint32
  attach_function :enet_time_set, [:uint32], :void
end
