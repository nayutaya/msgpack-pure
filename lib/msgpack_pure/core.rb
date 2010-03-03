# coding: utf-8

require "stringio"
require "msgpack_pure/packer"
require "msgpack_pure/unpacker"

module MessagePackPure
  def self.pack(value)
    io = StringIO.new
    Packer.write(io, value)
    return io.string
  end

  def self.unpack(binary)
    io = StringIO.new(binary, "r")
    return Unpacker.read(io)
  end
end
