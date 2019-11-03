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
