#! ruby -Ku
# coding: utf-8

require "test_helper"
require "stringio"
require "msgpack_pure/unpacker"

class UnpackerTest < Test::Unit::TestCase
  def setup
    @module = MessagePackPure::Unpacker
  end

  def test_unpack__positive_fixnum
    assert_equal(  0, unpack("\x00"))
    assert_equal(127, unpack("\x7F"))
  end

  def test_unpack__negative_fixnum
    assert_equal( -1, unpack("\xFF"))
    assert_equal(-32, unpack("\xE0"))
  end

  def test_unpack__uint8
    assert_equal(0,          unpack("\xCC\x00"))
    assert_equal(2 ** 8 - 1, unpack("\xCC\xFF"))
  end

  def test_unpack__uint16
    assert_equal(0,           unpack("\xCD\x00\x00"))
    assert_equal(1,           unpack("\xCD\x00\x01"))
    assert_equal(2 ** 16 - 1, unpack("\xCD\xFF\xFF"))
  end

  def test_unpack__uint32
    assert_equal(0,           unpack("\xCE\x00\x00\x00\x00"))
    assert_equal(1,           unpack("\xCE\x00\x00\x00\x01"))
    assert_equal(2 ** 32 - 1, unpack("\xCE\xFF\xFF\xFF\xFF"))
  end

  def test_unpack__uint64
    assert_equal(0,           unpack("\xCF\x00\x00\x00\x00\x00\x00\x00\x00"))
    assert_equal(1,           unpack("\xCF\x00\x00\x00\x00\x00\x00\x00\x01"))
    assert_equal(2 ** 64 - 1, unpack("\xCF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"))
  end

  def test_unpack__int8
    assert_equal(0,          unpack("\xD0\x00"))
    assert_equal(2 ** 7 - 1, unpack("\xD0\x7F"))
    assert_equal(-1,         unpack("\xD0\xFF"))
    assert_equal(-(2 ** 7),  unpack("\xD0\x80"))
  end

  def test_unpack__int16
    assert_equal(0,           unpack("\xD1\x00\x00"))
    assert_equal(2 ** 15 - 1, unpack("\xD1\x7F\xFF"))
    assert_equal(-1,          unpack("\xD1\xFF\xFF"))
    assert_equal(-(2 ** 15),  unpack("\xD1\x80\x00"))
  end

  def test_unpack__int32
    assert_equal(0,           unpack("\xD2\x00\x00\x00\x00"))
    assert_equal(2 ** 31 - 1, unpack("\xD2\x7F\xFF\xFF\xFF"))
    assert_equal(-1,          unpack("\xD2\xFF\xFF\xFF\xFF"))
    assert_equal(-(2 ** 31),  unpack("\xD2\x80\x00\x00\x00"))
  end

  def test_unpack__int64
    assert_equal(0,           unpack("\xD3\x00\x00\x00\x00\x00\x00\x00\x00"))
    assert_equal(2 ** 63 - 1, unpack("\xD3\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF"))
    assert_equal(-1,          unpack("\xD3\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"))
    assert_equal(-(2 ** 63),  unpack("\xD3\x80\x00\x00\x00\x00\x00\x00\x00"))
  end

  def test_unpack__nil
    assert_equal(nil, unpack("\xC0"))
  end

  def test_unpack__true
    assert_equal(true, unpack("\xC3"))
  end

  def test_unpack__false
    assert_equal(false, unpack("\xC2"))
  end

  def test_unpack__float
    assert_equal(0.0,  unpack("\xCA\x00\x00\x00\x00"))
    assert_equal(0.5,  unpack("\xCA\x3F\x00\x00\x00"))
    assert_equal(-0.5, unpack("\xCA\xBF\x00\x00\x00"))
  end

  def test_unpack__double
    assert_equal(0.0,  unpack("\xCB\x00\x00\x00\x00\x00\x00\x00\x00"))
    assert_equal(0.5,  unpack("\xCB\x3F\xE0\x00\x00\x00\x00\x00\x00"))
    assert_equal(-0.5, unpack("\xCB\xBF\xE0\x00\x00\x00\x00\x00\x00"))
  end

  def test_unpack__fixraw
    assert_equal("",       unpack("\xA0"))
    assert_equal("ABC",    unpack("\xA3ABC"))
    assert_equal("A" * 31, unpack("\xBF" + "A" * 31))
  end

  def test_unpack__raw16
    assert_equal("",    unpack("\xDA\x00\x00"))
    assert_equal("ABC", unpack("\xDA\x00\x03ABC"))
    assert_equal(
      "A" * (2 ** 16 - 1),
      unpack("\xDA\xFF\xFF" + "A" * (2 ** 16 - 1)))
  end

  def test_unpack__raw32
    assert_equal("",    unpack("\xDB\x00\x00\x00\x00"))
    assert_equal("ABC", unpack("\xDB\x00\x00\x00\x03ABC"))
    assert_equal(
      "A" * (2 ** 16),
      unpack("\xDB\x00\x01\x00\x00" + "A" * (2 ** 16)))
  end

  def test_unpack__fixarray
    assert_equal([],        unpack("\x90"))
    assert_equal([0, 1, 2], unpack("\x93\x00\x01\x02"))
    assert_equal([0] * 15,  unpack("\x9F" + "\x00" * 15))
  end

  def test_unpack__array16
    assert_equal([],        unpack("\xDC\x00\x00"))
    assert_equal([0, 1, 2], unpack("\xDC\x00\x03\x00\x01\x02"))
    assert_equal(
      [0] * (2 ** 16 - 1),
      unpack("\xDC\xFF\xFF" + "\x00" * (2 ** 16 - 1)))
  end

  def test_unpack__array32
    assert_equal([],        unpack("\xDD\x00\x00\x00\x00"))
    assert_equal([0, 1, 2], unpack("\xDD\x00\x00\x00\x03\x00\x01\x02"))
    assert_equal(
      [0] * (2 ** 16),
      unpack("\xDD\x00\x01\x00\x00" + "\x00" * (2 ** 16)))
  end

  def test_unpack__fixmap
    assert_equal({}, unpack("\x80"))
    assert_equal(
      {0 => 1, 2 => 3},
      unpack("\x82\x00\x01\x02\x03"))
  end

  def test_unpack__map16
    assert_equal({}, unpack("\xDE\x00\x00"))
    assert_equal(
      {0 => 1, 2 => 3},
      unpack("\xDE\x00\x02\x00\x01\x02\x03"))

    hash = {}
    io   = StringIO.new
    io.write("\xDE\xFF\xFF")
    (2 ** 16 - 1).times { |i|
      hash[i] = 0
      io.write("\xCD") # uint16: i
      io.write([i].pack("n"))
      io.write("\x00") # fixnum: 0
    }
    io.rewind
    assert_equal(hash, @module.unpack(io))
  end

  def test_unpack__map32
    assert_equal({}, unpack("\xDF\x00\x00\x00\x00"))
    assert_equal(
      {0 => 1, 2 => 3},
      unpack("\xDF\x00\x00\x00\x02\x00\x01\x02\x03"))

    hash = {}
    io   = StringIO.new
    io.write("\xDF\x00\x01\x00\x00")
    (2 ** 16).times { |i|
      hash[i] = 0
      io.write("\xCD") # uint16: i
      io.write([i].pack("n"))
      io.write("\x00") # fixnum: 0
    }
    io.rewind
    assert_equal(hash, @module.unpack(io))
  end

  private

  def unpack(binary)
    return @module.unpack(StringIO.new(binary))
  end
end
