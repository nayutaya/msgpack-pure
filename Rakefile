
require "rake/testtask"
require "lib/msgpack_pure/version"

task :default => :test

Rake::TestTask.new do |test|
  test.libs << "test"
  test.test_files = Dir.glob("test/**/*_test.rb")
  test.verbose    =  true
end

desc "bump version"
task :version do
  cur_version  = MessagePackPure::VERSION
  next_version = cur_version.succ
  puts("#{cur_version} -> #{next_version}")

  filename = File.join(File.dirname(__FILE__), "lib", "msgpack_pure", "version.rb")
  File.open(filename, "wb") { |file|
    file.puts(%|# coding: utf-8|)
    file.puts(%||)
    file.puts(%|module MessagePackPure|)
    file.puts(%|  VERSION = "#{next_version}"|)
    file.puts(%|end|)
  }
end
