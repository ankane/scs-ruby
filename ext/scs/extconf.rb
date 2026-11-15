require "mkmf"

def run(*command)
  unless system(*command)
    raise "Command failed"
  end
end

arch = RbConfig::CONFIG["arch"]
puts "Arch: #{arch}"

scs = File.expand_path("../../vendor/scs", __dir__)
Dir.chdir(scs) do
  case arch
  when /mingw/
    run "ridk", "exec", "make", "USE_LAPACK=0"
  else
    run "make"
  end
end

File.write("Makefile", dummy_makefile("scs").join)
