# coding: utf-8

require "stringio"
require "msgpack_pure/packer"

module MessagePackPure
  def self.pack(value)
    io = StringIO.new
    Packer.write(io, value)
    return io.string
  end
end
