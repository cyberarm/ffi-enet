# frozen_string_literal: true

require "test_helper"

class TestEnet < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Enet::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
