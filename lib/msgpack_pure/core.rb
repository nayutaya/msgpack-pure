# coding: utf-8

require "stringio"
require "msgpack_pure/packer"
require "msgpack_pure/unpacker"

module MessagePackPure
  def self.pack(value)
    io = StringIO.new
    packer = Packer.new(io)
    packer.write(value)
    return io.string
  end

  def self.unpack(binary)
    io = StringIO.new(binary, "r")
    unpacker = Unpacker.new(io)
    return unpacker.read
  end
end
