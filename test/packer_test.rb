#! ruby -Ku
# coding: utf-8

require "test_helper"
require "stringio"
require "msgpack_pure/packer"

class PackerTest < Test::Unit::TestCase
  def setup
    @module = MessagePackPure::Packer
  end

  def test_fixnum__positive_fixnum
    assert_equal("\x00", @module.pack_fixnum(sio, 0x00).string)
    assert_equal("\x01", @module.pack_fixnum(sio, 0x01).string)
    assert_equal("\x7F", @module.pack_fixnum(sio, 0x7F).string)
  end

  def test_pack_nil
    assert_equal("\xC0", @module.pack_nil(sio).string)
  end

  def test_pack_true
    assert_equal("\xC3", @module.pack_true(sio).string)
  end

  def test_pack_false
    assert_equal("\xC2", @module.pack_false(sio).string)
  end

  private

  def sio
    return StringIO.new
  end
end
