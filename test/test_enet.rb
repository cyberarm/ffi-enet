# frozen_string_literal: true

require "test_helper"

class TestEnet < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ENet::VERSION
  end

  def test_that_a_address_can_be_created
    address = LibENet::ENetAddress.new

    result = LibENet.enet_address_set_host(address, "localhost")
    address[:port] = 45_001

    assert result.zero?
  end
end
