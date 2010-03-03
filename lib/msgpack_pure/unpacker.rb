# coding: utf-8

require "stringio"

module MessagePackPure
  module Unpacker
  end
end

module MessagePackPure::Unpacker
  def self.unpack(io)
    type = io.read(1).unpack("C")[0]

    if (type & 0b10000000) == 0b00000000 # positive fixnum
      return type
    elsif (type & 0b11100000) == 0b11100000 # negative fixnum
      return (type & 0b00011111) - 32
    elsif (type & 0b11100000) == 0b10100000 # fixraw
      size = (type & 0b00011111)
      return io.read(size)
    end

    case type
    when 0xC0 # nil
      return nil
    when 0xC2 # false
      return false
    when 0xC3 # true
      return true
    when 0xCB # double
      return io.read(8).unpack("G")[0]
    when 0xCC # uint8
      return io.read(1).unpack("C")[0]
    when 0xCD # uint16
      return io.read(2).unpack("n")[0]
    when 0xCE # uint32
      return io.read(4).unpack("N")[0]
    when 0xCF # uint64
      hi = io.read(4).unpack("N")[0]
      lo = io.read(4).unpack("N")[0]
      return (hi << 32) | lo
    when 0xD0 # int8
      return io.read(1).unpack("c")[0]
    else
      raise("Unknown Type -- #{'0x%02X' % type}")
    end
  end
end
