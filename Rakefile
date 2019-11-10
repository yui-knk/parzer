require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/extensiontask"

RSpec::Core::RakeTask.new(:spec)

spec = Gem::Specification.load("parzer.gemspec")
Rake::ExtensionTask.new("parzer", spec) do |ext|
  ext.lib_dir = "lib/parzer"
  ext.ext_dir = "ext/parzer"
  ext.source_pattern = "parzer.c"
end

task :default => :spec

namespace :parser do
  task :setup, ['name'] do |task, args|
    `cp ./misc/#{args[:name]}.c ./ext/parzer/parse.inc`
    `cp ./misc/#{args[:name]}.h ./ext/parzer/parse.h.inc`
  end
end
