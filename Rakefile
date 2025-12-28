require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

task default: :test

task :compile do
  sh "ruby ext/scs/extconf.rb"
end

CLEAN.include("vendor/scs/out")

task :remove_obj do
  Dir["vendor/scs/**/*.o"].each do |path|
    File.unlink(path)
  end
end

Rake::Task["build"].enhance [:remove_obj]
