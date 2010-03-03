#! ruby -Ku
# coding: utf-8

require "test_helper"
require "msgpack_pure/unpacker"

class UnpackerTest < Test::Unit::TestCase
  def setup
    @module = MessagePackPure::Unpacker
  end

  def test_positive_fixnum
    assert_equal(  0, @module.unpack(StringIO.new("\x00")))
    assert_equal(  1, @module.unpack(StringIO.new("\x01")))
    assert_equal(127, @module.unpack(StringIO.new("\x7F")))
  end

  def test_nil
    io = StringIO.new("\xC0")
    assert_equal(nil, @module.unpack(io))
  end

  def test_ok
    assert true
  end
end
