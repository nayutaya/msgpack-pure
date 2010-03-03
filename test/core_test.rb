#! ruby -Ku
# coding: utf-8

require "test_helper"
require "msgpack_pure/core"
require "rubygems"
require "msgpack"

class CoreTest < Test::Unit::TestCase
  def setup
    @module = MessagePackPure
  end

  def test_pack
    assert_equal("\x00", @module.pack(0))
    assert_equal("\xC0", @module.pack(nil))
  end

  def test_unpack
    assert_equal(0,   @module.unpack("\x00"))
    assert_equal(nil, @module.unpack("\xC0"))
  end

  def test_cross__primitive
    [
      0,                   # positive fixnum
      -1,                  # negative fixnum
      0xFF,                # uint8
      0xFFFF,              # uint16
      0xFFFFFFFF,          # uint32
      0xFFFFFFFFFFFFFFFF,  # uint64
      -0x80,               # int8
      -0x8000,             # int16
      -0x80000000,         # int32
      -0x8000000000000000, # int64
      nil,                 # nil
      true,                # true
      false,               # false
      0.5,                 # double
      "",                  # fixraw
      "A" * 0xFFFF,        # raw16
      "A" * 0x00010000,    # raw32
      [],                  # fixarray
      {},                  # fixmap
    ].each { |value|
      bin1   = MessagePack.pack(value)
      bin2   = MessagePackPure.pack(value)
      value1 = MessagePackPure.unpack(bin1)
      value2 = MessagePack.unpack(bin2)
      assert_equal(value, value1)
      assert_equal(value, value2)
      assert_equal(bin1, bin2)
    }
  end

  def test_cross__collection
    [
      (0..      0x0F).to_a, # fixarray
      (0..    0xFFFF).to_a, # array16
      (0..0x00010000).to_a, # array32
      (0..      0x0F).inject({}) { |memo, i| memo[i] = i; memo }, # fixmap
      (0..    0xFFFF).inject({}) { |memo, i| memo[i] = i; memo }, # map16
      (0..0x00010000).inject({}) { |memo, i| memo[i] = i; memo }, # map32
    ].each { |value|
      bin1   = MessagePack.pack(value)
      bin2   = MessagePackPure.pack(value)
      value1 = MessagePackPure.unpack(bin1)
      value2 = MessagePack.unpack(bin2)
      assert_equal(value, value1)
      assert_equal(value, value2)
    }
  end
end
