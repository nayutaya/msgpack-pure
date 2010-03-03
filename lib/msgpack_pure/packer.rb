# coding: utf-8

# MessagePack format specification
# http://msgpack.sourceforge.jp/spec

module MessagePackPure
  module Packer
  end
end

module MessagePackPure::Packer
  def self.pack(io, value)
    case value
    when Integer    then self.pack_integer(io, value)
    when NilClass   then self.pack_nil(io)
    when TrueClass  then self.pack_true(io)
    when FalseClass then self.pack_false(io)
    when Float      then self.pack_float(io, value)
    when String     then self.pack_string(io, value)
    when Array      then self.pack_array(io, value)
    when Hash       then self.pack_hash(io, value)
    else raise("unknown type")
    end
    return io
  end

  def self.pack_integer(io, num)
    case num
    when (-0x20..0x7F)
      io.write([num].pack("C"))
    when (0x00..0xFF)
      io.write("\xCC")
      io.write([num].pack("C"))
    when (-0x80..0x7F)
      io.write("\xD0")
      io.write([num].pack("c"))
    when (0x0000..0xFFFF)
      io.write("\xCD")
      io.write([num].pack("n"))
    when (-0x8000..0x7FFF)
      io.write("\xD1")
      num += (2 ** 16) if num < 0
      io.write([num].pack("n"))
    when (0x00000000..0xFFFFFFFF)
      io.write("\xCE")
      io.write([num].pack("N"))
    when (-0x80000000..0x7FFFFFFF)
      io.write("\xD2")
      num += (2 ** 32) if num < 0
      io.write([num].pack("N"))
    when (0x0000000000000000..0xFFFFFFFFFFFFFFFF)
      high = (num >> 32)
      low  = (num & 0xFFFFFFFF)
      io.write("\xCF")
      io.write([high].pack("N"))
      io.write([low].pack("N"))
    when (-0x8000000000000000..0x7FFFFFFFFFFFFFFF)
      num += (2 ** 64) if num < 0
      high = (num >> 32)
      low  = (num & 0xFFFFFFFF)
      io.write("\xD3")
      io.write([high].pack("N"))
      io.write([low].pack("N"))
    else
      raise("invalid integer")
    end
    return io
  end

  def self.pack_nil(io)
    io.write("\xC0")
    return io
  end

  def self.pack_true(io)
    io.write("\xC3")
    return io
  end

  def self.pack_false(io)
    io.write("\xC2")
    return io
  end

  def self.pack_float(io, value)
    io.write("\xCB")
    io.write([value].pack("G"))
    return io
  end

  def self.pack_string(io, value)
    case value.size
    when (0x00..0x1F)
      io.write([0b10100000 + value.size].pack("C"))
      io.write(value)
    when (0x0000..0xFFFF)
      io.write("\xDA")
      io.write([value.size].pack("n"))
      io.write(value)
    when (0x00000000..0xFFFFFFFF)
      io.write("\xDB")
      io.write([value.size].pack("N"))
      io.write(value)
    else
      raise("invalid length")
    end
  end

  def self.pack_array(io, value)
    case value.size
    when (0x00..0x0F)
      io.write([0b10010000 + value.size].pack("C"))
      value.each { |item| self.pack(io, item) }
    when (0x0000..0xFFFF)
      io.write("\xDC")
      io.write([value.size].pack("n"))
      value.each { |item| self.pack(io, item) }
    when (0x00000000..0xFFFFFFFF)
      io.write("\xDD")
      io.write([value.size].pack("N"))
      value.each { |item| self.pack(io, item) }
    end
  end

  def self.pack_hash(io, value)
    case value.size
    when (0x00..0x0F)
      io.write([0b10000000 + value.size].pack("C"))
      value.sort_by { |key, value| key }.each { |key, value|
        self.pack(io, key)
        self.pack(io, value)
      }
    end
  end
end
