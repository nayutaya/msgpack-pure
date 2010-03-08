#! ruby -Ku
# coding: utf-8

require "test_helper"
require "stringio"
require "msgpack_pure/unpacker"

class UnpackerTest < Test::Unit::TestCase
  def setup
    @klass = MessagePackPure::Unpacker
    @module = MessagePackPure::Unpacker
  end

  def test_initialize
    io       = StringIO.new
    unpacker = @klass.new(io)
    assert_same(io, unpacker.io)
  end

  def test_read__positive_fixnum
    assert_equal(+0x00, read("\x00"))
    assert_equal(+0x7F, read("\x7F"))
  end

  def test_read__negative_fixnum
    assert_equal(-0x01, read("\xFF"))
    assert_equal(-0x20, read("\xE0"))
  end

  def test_read__uint8
    assert_equal(+0x00, read("\xCC\x00"))
    assert_equal(+0xFF, read("\xCC\xFF"))
  end

  def test_read__uint16
    assert_equal(+0x0000, read("\xCD\x00\x00"))
    assert_equal(+0x0001, read("\xCD\x00\x01"))
    assert_equal(+0xFFFF, read("\xCD\xFF\xFF"))
  end

  def test_read__uint32
    assert_equal(+0x00000000, read("\xCE\x00\x00\x00\x00"))
    assert_equal(+0x00000001, read("\xCE\x00\x00\x00\x01"))
    assert_equal(+0xFFFFFFFF, read("\xCE\xFF\xFF\xFF\xFF"))
  end

  def test_read__uint64
    assert_equal(+0x0000000000000000, read("\xCF\x00\x00\x00\x00\x00\x00\x00\x00"))
    assert_equal(+0x0000000000000001, read("\xCF\x00\x00\x00\x00\x00\x00\x00\x01"))
    assert_equal(+0xFFFFFFFFFFFFFFFF, read("\xCF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"))
  end

  def test_read__int8
    assert_equal(+0x00, read("\xD0\x00"))
    assert_equal(+0x7F, read("\xD0\x7F"))
    assert_equal(-0x01, read("\xD0\xFF"))
    assert_equal(-0x80, read("\xD0\x80"))
  end

  def test_read__int16
    assert_equal(+0x0000, read("\xD1\x00\x00"))
    assert_equal(+0x7FFF, read("\xD1\x7F\xFF"))
    assert_equal(-0x0001, read("\xD1\xFF\xFF"))
    assert_equal(-0x8000, read("\xD1\x80\x00"))
  end

  def test_read__int32
    assert_equal(+0x00000000, read("\xD2\x00\x00\x00\x00"))
    assert_equal(+0x7FFFFFFF, read("\xD2\x7F\xFF\xFF\xFF"))
    assert_equal(-0x00000001, read("\xD2\xFF\xFF\xFF\xFF"))
    assert_equal(-0x80000000, read("\xD2\x80\x00\x00\x00"))
  end

  def test_read__int64
    assert_equal(+0x0000000000000000, read("\xD3\x00\x00\x00\x00\x00\x00\x00\x00"))
    assert_equal(+0x7FFFFFFFFFFFFFFF, read("\xD3\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF"))
    assert_equal(-0x0000000000000001, read("\xD3\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"))
    assert_equal(-0x8000000000000000, read("\xD3\x80\x00\x00\x00\x00\x00\x00\x00"))
  end

  def test_read__nil
    assert_equal(nil, read("\xC0"))
  end

  def test_read__true
    assert_equal(true, read("\xC3"))
  end

  def test_read__false
    assert_equal(false, read("\xC2"))
  end

  def test_read__float
    assert_equal(+0.0, read("\xCA\x00\x00\x00\x00"))
    assert_equal(+0.5, read("\xCA\x3F\x00\x00\x00"))
    assert_equal(-0.5, read("\xCA\xBF\x00\x00\x00"))
  end

  def test_read__double
    assert_equal(+0.0, read("\xCB\x00\x00\x00\x00\x00\x00\x00\x00"))
    assert_equal(+0.5, read("\xCB\x3F\xE0\x00\x00\x00\x00\x00\x00"))
    assert_equal(-0.5, read("\xCB\xBF\xE0\x00\x00\x00\x00\x00\x00"))
  end

  def test_read__fixraw
    assert_equal("",       read("\xA0"))
    assert_equal("ABC",    read("\xA3ABC"))
    assert_equal("A" * 31, read("\xBF" + "A" * 31))
  end

  def test_read__raw16
    assert_equal("",    read("\xDA\x00\x00"))
    assert_equal("ABC", read("\xDA\x00\x03ABC"))
    assert_equal(
      "A" * 0xFFFF,
      read("\xDA\xFF\xFF" + "A" * 0xFFFF))
  end

  def test_read__raw32
    assert_equal("",    read("\xDB\x00\x00\x00\x00"))
    assert_equal("ABC", read("\xDB\x00\x00\x00\x03ABC"))
    assert_equal(
      "A" * 0x10000,
      read("\xDB\x00\x01\x00\x00" + "A" * 0x10000))
  end

  def test_read__fixarray
    assert_equal([],        read("\x90"))
    assert_equal([0, 1, 2], read("\x93\x00\x01\x02"))

    io = StringIO.new("\x9F", "a+")
    array = 15.times.map { |i|
      io.write("\xCD" + [i].pack("n")) # uint16: i
      i
    }
    io.rewind
    assert_equal(array, @module.read(io))
  end

  def test_read__array16
    assert_equal([],        read("\xDC\x00\x00"))
    assert_equal([0, 1, 2], read("\xDC\x00\x03\x00\x01\x02"))

    io = StringIO.new("\xDC\xFF\xFF", "a+")
    array = 0xFFFF.times.map { |i|
      io.write("\xCD" + [i].pack("n")) # uint16: i
      i
    }
    io.rewind
    assert_equal(array, @module.read(io))
  end

  def test_read__array32
    assert_equal([],        read("\xDD\x00\x00\x00\x00"))
    assert_equal([0, 1, 2], read("\xDD\x00\x00\x00\x03\x00\x01\x02"))

    io = StringIO.new("\xDD\x00\x01\x00\x00", "a+")
    array = 0x10000.times.map { |i|
      io.write("\xCD" + [i].pack("n")) # uint16: i
      i
    }
    io.rewind
    assert_equal(array, @module.read(io))
  end

  def test_read__fixmap
    assert_equal({}, read("\x80"))
    assert_equal(
      {0 => 1, 2 => 3},
      read("\x82\x00\x01\x02\x03"))

    io = StringIO.new("\x8F", "a+")
    hash = 15.times.inject({}) { |memo, i|
      io.write("\xCD" + [i].pack("n")) # uint16: i
      io.write("\x00")                 # fixnum: 0
      memo[i] = 0
      memo
    }
    io.rewind
    assert_equal(hash, @module.read(io))
  end

  def test_read__map16
    assert_equal({}, read("\xDE\x00\x00"))
    assert_equal(
      {0 => 1, 2 => 3},
      read("\xDE\x00\x02\x00\x01\x02\x03"))

    io = StringIO.new("\xDE\xFF\xFF", "a+")
    hash = 0xFFFF.times.inject({}) { |memo, i|
      io.write("\xCD" + [i].pack("n")) # uint16: i
      io.write("\x00")                 # fixnum: 0
      memo[i] = 0
      memo
    }
    io.rewind
    assert_equal(hash, @module.read(io))
  end

  def test_read__map32
    assert_equal({}, read("\xDF\x00\x00\x00\x00"))
    assert_equal(
      {0 => 1, 2 => 3},
      read("\xDF\x00\x00\x00\x02\x00\x01\x02\x03"))

    io = StringIO.new("\xDF\x00\x01\x00\x00", "a+")
    hash = 0x10000.times.inject({}) { |memo, i|
      io.write("\xCD" + [i].pack("n")) # uint16: i
      io.write("\x00")                 # fixnum: 0
      memo[i] = 0
      memo
    }
    io.rewind
    assert_equal(hash, @module.read(io))
  end

  private

  def read(binary)
    return @module.read(StringIO.new(binary, "r"))
  end
end
