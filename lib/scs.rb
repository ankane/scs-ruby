# stdlib
require "fiddle/import"

# modules
require "scs/matrix"
require "scs/solver"
require "scs/version"

module SCS
  class Error < StandardError; end

  def self.lib_version
    FFI::Direct.scs_version.to_s
  end

  # friendlier error message
  autoload :FFI, "scs/ffi"
end
