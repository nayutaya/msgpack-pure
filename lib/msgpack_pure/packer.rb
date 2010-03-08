# coding: utf-8

# MessagePack format specification
# http://msgpack.sourceforge.jp/spec

module MessagePackPure
  class Packer
  end
end

class MessagePackPure::Packer
  def initialize(io)
    @io = io
  end

  attr_reader :io

  def self.write(io, value)
    packer = self.new(io)
    packer.write(value)
    return io
  end

  def write(value)
    case value
    when Integer    then self.class.write_integer(@io, value)
    when NilClass   then self.class.write_nil(@io)
    when TrueClass  then self.class.write_true(@io)
    when FalseClass then self.class.write_false(@io)
    when Float      then self.class.write_float(@io, value)
    when String     then self.class.write_string(@io, value)
    when Array      then self.class.write_array(@io, value)
    when Hash       then self.class.write_hash(@io, value)
    else raise("unknown type")
    end

    return @io
  end

  def self.write_integer(io, num)
    case num
    when (-0x20..0x7F)
      # positive fixnum, negative fixnum
      io.write(self.pack_int8(num))
    when (0x00..0xFF)
      # uint8
      io.write("\xCC")
      io.write(self.pack_uint8(num))
    when (-0x80..0x7F)
      # int8
      io.write("\xD0")
      io.write(self.pack_int8(num))
    when (0x0000..0xFFFF)
      # uint16
      io.write("\xCD")
      io.write(self.pack_uint16(num))
    when (-0x8000..0x7FFF)
      # int16
      io.write("\xD1")
      io.write(self.pack_int16(num))
    when (0x00000000..0xFFFFFFFF)
      # uint32
      io.write("\xCE")
      io.write(self.pack_uint32(num))
    when (-0x80000000..0x7FFFFFFF)
      # int32
      io.write("\xD2")
      io.write(self.pack_int32(num))
    when (0x0000000000000000..0xFFFFFFFFFFFFFFFF)
      # uint64
      io.write("\xCF")
      io.write(self.pack_uint64(num))
    when (-0x8000000000000000..0x7FFFFFFFFFFFFFFF)
      # int64
      io.write("\xD3")
      io.write(self.pack_int64(num))
    else
      raise("invalid integer")
    end
  end

  def self.write_nil(io)
    io.write("\xC0")
  end

  def self.write_true(io)
    io.write("\xC3")
  end

  def self.write_false(io)
    io.write("\xC2")
  end

  def self.write_float(io, value)
    io.write("\xCB")
    io.write(self.pack_double(value))
  end

  def self.write_string(io, value)
    case value.size
    when (0x00..0x1F)
      # fixraw
      io.write(self.pack_uint8(0b10100000 + value.size))
      io.write(value)
    when (0x0000..0xFFFF)
      # raw16
      io.write("\xDA")
      io.write(self.pack_uint16(value.size))
      io.write(value)
    when (0x00000000..0xFFFFFFFF)
      # raw32
      io.write("\xDB")
      io.write(self.pack_uint32(value.size))
      io.write(value)
    else
      raise("invalid length")
    end
  end

  def self.write_array(io, value)
    case value.size
    when (0x00..0x0F)
      # fixarray
      io.write(self.pack_uint8(0b10010000 + value.size))
    when (0x0000..0xFFFF)
      # array16
      io.write("\xDC")
      io.write(self.pack_uint16(value.size))
    when (0x00000000..0xFFFFFFFF)
      # array32
      io.write("\xDD")
      io.write(self.pack_uint32(value.size))
    else
      raise("invalid length")
    end

    value.each { |item|
      self.write(io, item)
    }
  end

  def self.write_hash(io, value)
    case value.size
    when (0x00..0x0F)
      # fixmap
      io.write(self.pack_uint8(0b10000000 + value.size))
    when (0x0000..0xFFFF)
      # map16
      io.write("\xDE")
      io.write(self.pack_uint16(value.size))
    when (0x00000000..0xFFFFFFFF)
      # map32
      io.write("\xDF")
      io.write(self.pack_uint32(value.size))
    else
      raise("invalid length")
    end

    value.sort_by { |key, value| key }.each { |key, value|
      self.write(io, key)
      self.write(io, value)
    }
  end

  def self.pack_uint8(value)
    return [value].pack("C")
  end

  def self.pack_int8(value)
    return [value].pack("c")
  end

  def self.pack_uint16(value)
    return [value].pack("n")
  end

  def self.pack_int16(value)
    value += (2 ** 16) if value < 0
    return self.pack_uint16(value)
  end

  def self.pack_uint32(value)
    return [value].pack("N")
  end

  def self.pack_int32(value)
    value += (2 ** 32) if value < 0
    return self.pack_uint32(value)
  end

  def self.pack_uint64(value)
    high = (value >> 32)
    low  = (value & 0xFFFFFFFF)
    return self.pack_uint32(high) + self.pack_uint32(low)
  end

  def self.pack_int64(value)
    value += (2 ** 64) if value < 0
    return self.pack_uint64(value)
  end

  def self.pack_double(value)
    return [value].pack("G")
  end
end
