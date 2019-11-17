require "mkmf"

scs = File.expand_path("../../vendor/scs", __dir__)

def inreplace(file, pattern, replacement)
  contents = File.read(file)
  File.write(file, contents.gsub(pattern, replacement))
end

unless have_library("blas") && have_library("lapack")
  inreplace("#{scs}/scs.mk", "USE_LAPACK = 1", "USE_LAPACK = 0")
end

Dir.chdir(scs) do
  system "make"
end

File.write("Makefile", dummy_makefile("scs").join)
