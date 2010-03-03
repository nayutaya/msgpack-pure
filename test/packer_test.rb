#! ruby -Ku
# coding: utf-8

require "test_helper"
require "stringio"
require "msgpack_pure/packer"

class PackerTest < Test::Unit::TestCase
  def setup
    @module = MessagePackPure::Packer
    @io     = StringIO.new
  end

  def test_pack_nil
    assert_equal("\xC0", @module.pack_nil(@io).string)
  end

  def test_pack_true
    assert_equal("\xC3", @module.pack_true(@io).string)
  end

  def test_pack_false
    assert_equal("\xC2", @module.pack_false(@io).string)
  end
end
