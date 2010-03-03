# coding: utf-8

# MessagePack format specification
# http://msgpack.sourceforge.jp/spec

module MessagePackPure
  module Packer
  end
end

module MessagePackPure::Packer
  def self.pack_fixnum(io, num)
    case num
    when (-32..127)
      io.write([num].pack("C"))
    when (0..0xFF)
      io.write("\xCC")
      io.write([num].pack("C"))
    when (0..0xFFFF)
      io.write("\xCD")
      io.write([num].pack("n"))
    else
      io.write("\xCE")
      io.write([num].pack("N"))
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
end
