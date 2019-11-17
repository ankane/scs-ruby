require "mkmf"

def run(command)
  puts ">> #{command}"
  unless system(command)
    raise "Command failed"
  end
end

def inreplace(file, pattern, replacement)
  contents = File.read(file)
  File.write(file, contents.gsub(pattern, replacement))
end

arch = RbConfig::CONFIG["arch"]
puts "Arch: #{arch}"

scs = File.expand_path("../../vendor/scs", __dir__)
Dir.chdir(scs) do
  case arch
  when /mingw/
    inreplace("scs.mk", "USE_LAPACK = 1", "USE_LAPACK = 0")
    run "ridk exec make"
  else
    run "make"
  end
end

File.write("Makefile", dummy_makefile("scs").join)
