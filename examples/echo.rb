require_relative "../lib/ffi-enet"
require_relative "../lib/ffi-enet/renet"

Thread.new do
  server = ENet::Server.new(host: "localhost", port: 3000, max_clients: 32, channels: 4, download_bandwidth: 0, upload_bandwidth: 0)
  server.use_compression(true)
  # server.use_compression(false)

  def server.on_connection(client)
    puts "[SERVER][ID #{client.id}] connected from #{client.address.host}:#{client.address.port}"
    send_packet(client, "Hello World", reliable: true, channel: 1)
  end

  def server.on_packet_received(client, data, channel)
    puts "[SERVER][ID #{client.id}] #{data}"
    send_packet(client, data, reliable: true, channel: 1)
  end

  def server.on_disconnection(client)
    puts "[SERVER][ID #{client.id}] disconnected from #{client.address.host}"
    send_packet(client, "Goodbye World", reliable: true, channel: 1)
  end

  loop do
    server.update(1_000)
  end
end

sleep 0.5

connection = ENet::Connection.new(host: "localhost", port: 3000, channels: 4, download_bandwidth: 0, upload_bandwidth: 0)
connection.use_compression(true)
# connection.use_compression(false)

def connection.on_connection
  puts "[CONNECTION] CONNECTED TO SERVER"
  send_packet("Hello World!", reliable: true, channel: 0)
end

def connection.on_packet_received(data, channel)
  puts "[CONNECTION][CHANNEL #{channel}]: #{data}"

  send_packet(data, reliable: true, channel: channel)
end

def connection.on_disconnection
  puts "[CONNECTION] DISCONNECTED FROM SERVER"
end

connection.connect(5_000)

loop do
  connection.update(1_000)
end
