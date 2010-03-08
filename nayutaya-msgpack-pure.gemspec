
Gem::Specification.new do |s|
  s.specification_version     = 2
  s.required_rubygems_version = Gem::Requirement.new(">= 0")
  s.required_ruby_version     = Gem::Requirement.new(">= 1.8.6")

  s.name    = "nayutaya-msgpack-pure"
  s.version = "0.0.0"
  s.date    = "2010-03-08"

  s.authors = ["Yuya Kato"]
  s.email   = "yuyakato@gmail.com"

  s.summary     = "MessagePack"
  s.description = "pure ruby implementation of MessagePack"
  s.homepage    = "http://github.com/nayutaya/msgpack-pure/"

  s.rubyforge_project = nil
  s.has_rdoc          = false
  s.require_paths     = ["lib"]

  s.files = [
    "lib/msgpack_pure/core.rb",
    "lib/msgpack_pure/packer.rb",
    "lib/msgpack_pure/unpacker.rb",
    "lib/msgpack_pure/version.rb",
    "lib/msgpack_pure.rb",
    "nayutaya-msgpack-pure.gemspec",
    "nayutaya-msgpack-pure.gemspec.erb",
    "Rakefile",
    "README.md",
    "test/core_test.rb",
    "test/packer_test.rb",
    "test/test_helper.rb",
    "test/unpacker_test.rb",
  ]
  s.test_files = [
    "test/core_test.rb",
    "test/packer_test.rb",
    "test/test_helper.rb",
    "test/unpacker_test.rb",
  ]
  s.extra_rdoc_files = []
end
