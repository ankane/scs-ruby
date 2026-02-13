module SCS
  class Solver
    def initialize(indirect: false)
      @ffi = indirect ? FFI::Indirect : FFI::Direct
      @refs = []
    end

    def solve(data, cone, **settings)
      cdata = create_data(data)
      settings = create_settings(settings)
      ccone = create_cone(cone)

      # alloc pointers and hold refs
      solution_ptr = Fiddle::Pointer["\x00" * ffi::Solution.size] # alloc clear memory
      x_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE * cdata.n, Fiddle::RUBY_FREE)
      y_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE * cdata.m, Fiddle::RUBY_FREE)
      s_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE * cdata.m, Fiddle::RUBY_FREE)

      solution = ffi::Solution.new(solution_ptr)
      solution.x = x_ptr
      solution.y = y_ptr
      solution.s = s_ptr

      info = ffi::Info.malloc(Fiddle::RUBY_FREE)

      ffi.scs(cdata, ccone, settings, solution, info)

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
        comp_slack: info.comp_slack,
        rejected_accel_steps: info.rejected_accel_steps,
        accepted_accel_steps: info.accepted_accel_steps,
        lin_sys_time: info.lin_sys_time,
        cone_time: info.cone_time,
        accel_time: info.accel_time
      }
    ensure
      @refs.clear
    end

    private

    def check_result(ret)
      raise Error, "Error code #{ret}" if ret != 0
    end

    def float_array(arr)
      # SCS float = double
      ptr = Fiddle::Pointer[arr.to_a.pack("d*")]
      @refs << ptr
      ptr
    end

    def read_float_array(ptr, size)
      # SCS float = double
      ptr[0, size * Fiddle::SIZEOF_DOUBLE].unpack("d*")
    end

    def int_array(arr)
      # SCS int = int
      ptr = Fiddle::Pointer[arr.to_a.pack("i!*")]
      @refs << ptr
      ptr
    end

    def read_string(char_ptr)
      idx = char_ptr.index { |v| v == 0 }
      char_ptr[0, idx].map(&:chr).join
    end

    def csc_matrix(mtx, upper: false)
      mtx = Matrix.from_dense(mtx) unless mtx.is_a?(Matrix)

      if upper
        # TODO improve performance
        mtx = mtx.dup
        mtx.m.times do |i|
          mtx.n.times do |j|
            mtx[i, j] = 0 if i > j
          end
        end
      end

      csc = mtx.to_csc

      # construct matrix
      matrix = ffi::Matrix.malloc(Fiddle::RUBY_FREE)
      matrix.x = float_array(csc[:value])
      matrix.i = int_array(csc[:index])
      matrix.p = int_array(csc[:start])
      matrix.m = mtx.m
      matrix.n = mtx.n
      @refs << matrix
      matrix
    end

    def shape(a)
      if a.is_a?(Matrix)
        [a.m, a.n]
      elsif defined?(::Matrix) && a.is_a?(::Matrix)
        [a.row_count, a.column_count]
      elsif defined?(Numo::NArray) && a.is_a?(Numo::NArray)
        a.shape
      else
        [a.size, a.first.size]
      end
    end

    def create_data(data)
      m, n = shape(data[:a])
      cdata = ffi::Data.malloc(Fiddle::RUBY_FREE)
      cdata.m = m
      cdata.n = n
      cdata.a = csc_matrix(data[:a])

      if data[:p]
        raise ArgumentError, "Bad p shape" if shape(data[:p]) != [n, n]
        cdata.p = csc_matrix(data[:p], upper: true)
      end

      raise ArgumentError, "Bad b size" if data[:b].to_a.size != m
      cdata.b = float_array(data[:b])

      raise ArgumentError, "Bad c size" if data[:c].to_a.size != n
      cdata.c = float_array(data[:c])
      cdata
    end

    def create_cone(cone)
      ccone = ffi::Cone.malloc(Fiddle::RUBY_FREE)
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
      set = ffi::Settings.malloc(Fiddle::RUBY_FREE)
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

    def ffi
      @ffi
    end
  end
end
