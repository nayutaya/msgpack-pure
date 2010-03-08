
require "rake/testtask"
require "lib/msgpack_pure/version"

NAME = "nayutaya-msgpack-pure"

task :default => :test

Rake::TestTask.new do |test|
  test.libs << "test"
  test.test_files = Dir.glob("test/**/*_test.rb")
  test.verbose    =  true
end

desc "bump version"
task :bump do
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

desc "generate gemspec"
task :gemspec do
  require "erb"

  src  = File.open("#{NAME}.gemspec.erb", "rb") { |file| file.read }
  erb  = ERB.new(src, nil, "-")

  version = MessagePackPure::VERSION
  date    = Time.now.strftime("%Y-%m-%d")

  files      = Dir.glob("**/*").select { |s| File.file?(s) }.reject { |s| /\.gem\z/ =~ s }
  test_files = Dir.glob("test/**").select { |s| File.file?(s) }

  File.open("#{NAME}.gemspec", "wb") { |file|
    file.write(erb.result(binding))
  }
end
