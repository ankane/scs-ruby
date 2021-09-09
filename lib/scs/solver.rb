module SCS
  class Solver
    def initialize(indirect: false)
      @ffi = indirect ? FFI::Indirect : FFI::Direct
    end

    def solve(data, cone, **settings)
      cdata = create_data(data)
      settings = create_settings(settings)
      ccone = create_cone(cone)

      solution = calloc(ffi::Solution.size) # alloc clear memory
      info = ffi::Info.malloc

      ffi.scs(cdata, ccone, settings, solution, info)

      solution = ffi::Solution.new(solution)
      x = read_float_array(solution.x, cdata.n)
      y = read_float_array(solution.y, cdata.m)
      s = read_float_array(solution.s, cdata.m)

      {
        x: x,
        y: y,
        s: s,
        iter: info.iter,
        status: read_string(info.status),
        status_val: info.status_val,
        scale_updates: info.scale_updates,
        pobj: info.pobj,
        dobj: info.dobj,
        res_pri: info.res_pri,
        res_dual: info.res_dual,
        gap: info.gap,
        res_infeas: info.res_infeas,
        res_unbdd_a: info.res_unbdd_a,
        res_unbdd_p: info.res_unbdd_p,
        setup_time: info.setup_time,
        solve_time: info.solve_time,
        scale: info.scale,
        comp_slack: info.comp_slack
      }
    end

    private

    def check_result(ret)
      raise Error, "Error code #{ret}" if ret != 0
    end

    def float_array(arr)
      # SCS float = double
      Fiddle::Pointer[arr.to_a.pack("d*")]
    end

    def read_float_array(ptr, size)
      # SCS float = double
      ptr[0, size * Fiddle::SIZEOF_DOUBLE].unpack("d*")
    end

    def int_array(arr)
      # SCS int = int
      Fiddle::Pointer[arr.to_a.pack("i!*")]
    end

    def read_string(char_ptr)
      idx = char_ptr.index { |v| v == 0 }
      char_ptr[0, idx].map(&:chr).join
    end

    # TODO add support sparse matrices
    def csc_matrix(mtx, upper: false)
      mtx = mtx.to_a

      m, n = shape(mtx)

      cx = []
      ci = []
      cp = []

      # CSC format
      # https://www.gormanalysis.com/blog/sparse-matrix-storage-formats/
      cp << 0
      n.times do |j|
        mtx.each_with_index do |row, i|
          if row[j] != 0 && (!upper || i <= j)
            cx << row[j]
            ci << i
          end
        end
        # cumulative column values
        cp << cx.size
      end

      # construct matrix
      matrix = ffi::Matrix.malloc
      matrix.x = float_array(cx)
      matrix.i = int_array(ci)
      matrix.p = int_array(cp)
      matrix.m = m
      matrix.n = n
      matrix
    end

    def shape(a)
      if defined?(Matrix) && a.is_a?(Matrix)
        [a.row_count, a.column_count]
      elsif defined?(Numo::NArray) && a.is_a?(Numo::NArray)
        a.shape
      else
        [a.size, a.first.size]
      end
    end

    def create_data(data)
      m, n = shape(data[:a])
      cdata = ffi::Data.malloc
      cdata.m = m
      cdata.n = n
      cdata.a = csc_matrix(data[:a])
      cdata.p = csc_matrix(data[:p]) if data[:p]
      cdata.b = float_array(data[:b])
      cdata.c = float_array(data[:c])
      cdata
    end

    def create_cone(cone)
      ccone = ffi::Cone.malloc
      ccone.z = cone[:z].to_i
      ccone.l = cone[:l].to_i
      ccone.bu = float_array(cone[:bu])
      ccone.bl = float_array(cone[:bl])
      if cone[:bu].to_a.size != cone[:bl].to_a.size
        raise ArgumentError, "Expected bu and bl size to match"
      end
      ccone.bsize = cone[:bu].to_a.size
      ccone.q = int_array(cone[:q])
      ccone.qsize = cone[:q].to_a.size
      ccone.s = int_array(cone[:s])
      ccone.ssize = cone[:s].to_a.size
      ccone.ep = cone[:ep].to_i
      ccone.ed = cone[:ed].to_i
      ccone.p = float_array(cone[:p])
      ccone.psize = cone[:p].to_a.size
      ccone
    end

    def create_settings(settings)
      set = ffi::Settings.malloc
      ffi.scs_set_default_settings(set)

      # hack for setting members with []=
      # safer than send("#{k}=", v)
      entity = set.to_ptr
      settings.each do |k, v|
        entity[k.to_s] = settings_value(v)
      end

      set
    end

    # handle booleans
    def settings_value(v)
      case v
      when true
        1
      when false
        0
      else
        v
      end
    end

    # alloc clear memory
    def calloc(size)
      Fiddle::Pointer["\x00" * size]
    end

    def ffi
      @ffi
    end
  end
end
