# stdlib
require "fiddle/import"

# modules
require_relative "scs/matrix"
require_relative "scs/solver"
require_relative "scs/version"

module SCS
  class Error < StandardError; end

  def self.lib_version
    FFI::Direct.scs_version.to_s
  end

  # friendlier error message
  autoload :FFI, "scs/ffi"
end
