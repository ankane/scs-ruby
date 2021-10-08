require "bundler/gem_tasks"
require "rake/testtask"

task default: :test
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.warning = false
end

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
