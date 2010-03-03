#! ruby -Ku
# coding: utf-8

require "test_helper"
require "stringio"
require "msgpack_pure/packer"

class PackerTest < Test::Unit::TestCase
  def setup
    @module = MessagePackPure::Packer
  end

  def test_pack_fixnum__positive_fixnum
    assert_equal("\x00", @module.pack_fixnum(sio, 0x00).string)
    assert_equal("\x01", @module.pack_fixnum(sio, 0x01).string)
    assert_equal("\x7F", @module.pack_fixnum(sio, 0x7F).string)
  end

  def test_pack_fixnum__negative_fixnum
    assert_equal("\xFF", @module.pack_fixnum(sio, -0x01).string)
    assert_equal("\xE0", @module.pack_fixnum(sio, -0x20).string)
  end

  def test_pack_fixnum__uint8
    assert_equal("\xCC\x80", @module.pack_fixnum(sio, 0x80).string)
    assert_equal("\xCC\xFF", @module.pack_fixnum(sio, 0xFF).string)
  end

  def test_pack_fixnum__uint16
    assert_equal("\xCD\x01\x00", @module.pack_fixnum(sio, 0x0100).string)
    assert_equal("\xCD\xFF\xFF", @module.pack_fixnum(sio, 0xFFFF).string)
  end

  def test_pack_fixnum__uint32
    assert_equal("\xCE\x00\x01\x00\x00", @module.pack_fixnum(sio, 0x00010000).string)
    assert_equal("\xCE\xFF\xFF\xFF\xFF", @module.pack_fixnum(sio, 0xFFFFFFFF).string)
  end

  def test_pack__nil
    assert_equal("\xC0", @module.pack(sio, nil).string)
  end

  def test_pack__true
    assert_equal("\xC3", @module.pack(sio, true).string)
  end

  def test_pack__false
    assert_equal("\xC2", @module.pack(sio, false).string)
  end

  private

  def sio
    return StringIO.new
  end
end
