module SCS
  module FFI
    module Direct
      def self.lib_name
        "libscsdir"
      end
    end

    module Indirect
      def self.lib_name
        "libscsindir"
      end
    end

    ext =
      if Gem.win_platform?
        "dll"
      elsif RbConfig::CONFIG["host_os"] =~ /darwin/i
        "dylib"
      else
        "so"
      end

    [Direct, Indirect].each do |m|
      m.module_eval do
        extend Fiddle::Importer

        dlload File.expand_path("../../vendor/scs/out/#{lib_name}.#{ext}", __dir__)

        extern "size_t scs_sizeof_int(void)"
        extern "size_t scs_sizeof_float(void)"

        # TODO support other sizes
        raise Error, "Unsupported int size" if scs_sizeof_int != 4
        raise Error, "Unsupported float size" if scs_sizeof_float != 8

        typealias "scs_float", "double"
        typealias "scs_int", "int"

        m::Data = struct [
          "scs_int m",
          "scs_int n",
          "ScsMatrix *a",
          "scs_float *b",
          "scs_float *c",
          "ScsSettings *stgs"
        ]

        m::Cone = struct [
          "scs_int f",
          "scs_int l",
          "scs_int *q",
          "scs_int qsize",
          "scs_int *s",
          "scs_int ssize",
          "scs_int ep",
          "scs_int ed",
          "scs_float *p",
          "scs_int psize",
        ]

        m::Solution = struct [
          "scs_float *x",
          "scs_float *y",
          "scs_float *s"
        ]

        m::Info = struct [
          "scs_int iter",
          "char status[32]",
          "scs_int status_val",
          "scs_float pobj",
          "scs_float dobj",
          "scs_float res_pri",
          "scs_float res_dual",
          "scs_float res_infeas",
          "scs_float res_unbdd",
          "scs_float rel_gap",
          "scs_float setup_time",
          "scs_float solve_time"
        ]

        m::Settings = struct [
          "scs_int normalize",
          "scs_float scale",
          "scs_float rho_x",
          "scs_int max_iters",
          "scs_float eps",
          "scs_float alpha",
          "scs_float cg_rate",
          "scs_int verbose",
          "scs_int warm_start",
          "scs_int acceleration_lookback",
          "const char* write_data_filename"
        ]

        m::Matrix = struct [
          "scs_float *x",
          "scs_int *i",
          "scs_int *p",
          "scs_int m",
          "scs_int n"
        ]

        # scs.h
        extern "ScsWork *scs_init(const ScsData *d, const ScsCone *k, ScsInfo *info)"
        extern "scs_int scs_solve(ScsWork *w, const ScsData *d, const ScsCone *k, ScsSolution *sol, ScsInfo *info)"
        extern "void scs_finish(ScsWork *w)"
        extern "scs_int scs(const ScsData *d, const ScsCone *k, ScsSolution *sol, ScsInfo *info)"
        extern "const char *scs_version(void)"

        # utils.h
        extern "void scs_set_default_settings(ScsData *d)"
      end
    end
  end
end
