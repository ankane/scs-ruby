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

        typealias "scs_float", "double"
        typealias "scs_int", "int"

        m::Data = struct [
          "scs_int m",
          "scs_int n",
          "ScsMatrix *a",
          "ScsMatrix *p",
          "scs_float *b",
          "scs_float *c"
        ]

        m::Cone = struct [
          "scs_int z",
          "scs_int l",
          "scs_float *bu",
          "scs_float *bl",
          "scs_int *bsize",
          "scs_int *q",
          "scs_int qsize",
          "scs_int *s",
          "scs_int ssize",
          "scs_int ep",
          "scs_int ed",
          "scs_float *p",
          "scs_int psize"
        ]

        m::Solution = struct [
          "scs_float *x",
          "scs_float *y",
          "scs_float *s"
        ]

        m::Info = struct [
          "scs_int iter",
          "char status[128]",
          "char lin_sys_solver[128]",
          "scs_int status_val",
          "scs_int scale_updates",
          "scs_float pobj",
          "scs_float dobj",
          "scs_float res_pri",
          "scs_float res_dual",
          "scs_float gap",
          "scs_float res_infeas",
          "scs_float res_unbdd_a",
          "scs_float res_unbdd_p",
          "scs_float setup_time",
          "scs_float solve_time",
          "scs_float scale",
          "scs_float comp_slack",
          "scs_int rejected_accel_steps",
          "scs_int accepted_accel_steps",
          "scs_float lin_sys_time",
          "scs_float cone_time",
          "scs_float accel_time"
        ]

        m::Settings = struct [
          "scs_int normalize",
          "scs_float scale",
          "scs_int adaptive_scale",
          "scs_float rho_x",
          "scs_int max_iters",
          "scs_float eps_abs",
          "scs_float eps_rel",
          "scs_float eps_infeas",
          "scs_float alpha",
          "scs_float time_limit_secs",
          "scs_int verbose",
          "scs_int warm_start",
          "scs_int acceleration_lookback",
          "scs_int acceleration_interval",
          "const char* write_data_filename",
          "const char *log_csv_filename"
        ]

        m::Matrix = struct [
          "scs_float *x",
          "scs_int *i",
          "scs_int *p",
          "scs_int m",
          "scs_int n"
        ]

        # scs.h
        extern "ScsWork *scs_init(const ScsData *d, const ScsCone *k, const ScsSettings *stgs)"
        extern "scs_int scs_solve(ScsWork *w, ScsSolution *sol, ScsInfo *info)"
        extern "void scs_finish(ScsWork *w)"
        extern "scs_int scs(const ScsData *d, const ScsCone *k, const ScsSettings *stgs, ScsSolution *sol, ScsInfo *info)"
        extern "const char *scs_version(void)"

        # utils.h
        extern "void scs_set_default_settings(ScsSettings *stgs)"
      end
    end
  end
end
