require "mkmf"

scs = File.expand_path("../../vendor/scs", __dir__)
Dir.chdir(scs) do
  system "make"
end

File.write("Makefile", dummy_makefile("scs").join)
