# coding: utf-8

require "stringio"

module MessagePackPure
  module Unpacker
  end
end

module MessagePackPure::Unpacker
  def self.unpack(io)
    type = self.read_uint8(io)

    case
    when (type & 0b10000000) == 0b00000000 # positive fixnum
      return type
    when (type & 0b11100000) == 0b11100000 # negative fixnum
      return (type & 0b00011111) - (2 ** 5)
    when (type & 0b11100000) == 0b10100000 # fixraw
      size = (type & 0b00011111)
      return io.read(size)
    when (type & 0b11110000) == 0b10010000 # fixarray
      size = (type & 0b00001111)
      return self.unpack_array(io, size)
    when (type & 0b11110000) == 0b10000000 # fixmap
      size = (type & 0b00001111)
      return self.unpack_hash(io, size)
    end

    case type
    when 0xC0 # nil
      return nil
    when 0xC2 # false
      return false
    when 0xC3 # true
      return true
    when 0xCA # float
      return io.read(4).unpack("g")[0]
    when 0xCB # double
      return io.read(8).unpack("G")[0]
    when 0xCC # uint8
      return self.read_uint8(io)
    when 0xCD # uint16
      return self.read_uint16(io)
    when 0xCE # uint32
      return self.read_uint32(io)
    when 0xCF # uint64
      return self.read_uint64(io)
    when 0xD0 # int8
      return io.read(1).unpack("c")[0]
    when 0xD1 # int16
      num = self.read_uint16(io)
      return (num < 2 ** 15 ? num : num - (2 ** 16))
    when 0xD2 # int32
      num = self.read_uint32(io)
      return (num < 2 ** 31 ? num : num - (2 ** 32))
    when 0xD3 # int64
      num = self.read_uint64(io)
      return (num < 2 ** 63 ? num : num - (2 ** 64))
    when 0xDA # raw16
      size = self.read_uint16(io)
      return io.read(size)
    when 0xDB # raw32
      size = self.read_uint32(io)
      return io.read(size)
    when 0xDC # array16
      size = self.read_uint16(io)
      return self.unpack_array(io, size)
    when 0xDD # array32
      size = self.read_uint32(io)
      return self.unpack_array(io, size)
    when 0xDE # map16
      size = self.read_uint16(io)
      return self.unpack_hash(io, size)
    when 0xDF # map32
      size = self.read_uint32(io)
      return self.unpack_hash(io, size)
    else
      raise("Unknown Type -- #{'0x%02X' % type}")
    end
  end

  def self.unpack_array(io, size)
    return size.times.map { self.unpack(io) }
  end

  def self.unpack_hash(io, size)
    return size.times.inject({}) { |memo,|
      memo[self.unpack(io)] = self.unpack(io)
      memo
    }
  end

  def self.read_uint8(io)
    return io.read(1).unpack("C")[0]
  end

  def self.read_uint16(io)
    return io.read(2).unpack("n")[0]
  end

  def self.read_uint32(io)
    return io.read(4).unpack("N")[0]
  end

  def self.read_uint64(io)
    high = self.read_uint32(io)
    low  = self.read_uint32(io)
    return (high << 32) + low
  end
end
