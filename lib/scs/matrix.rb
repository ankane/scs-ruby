module SCS
  class Matrix
    attr_reader :m, :n

    def initialize(m, n)
      @m = m
      @n = n
      @data = {}
    end

    def []=(row_index, column_index, value)
      raise IndexError, "row index out of bounds" if row_index < 0 || row_index >= @m
      raise IndexError, "column index out of bounds" if column_index < 0 || column_index >= @n
      # dictionary of keys, optimized for converting to CSC
      # TODO try COO for performance
      if value == 0
        (@data[column_index] ||= {}).delete(row_index)
      else
        (@data[column_index] ||= {})[row_index] = value
      end
    end

    def to_csc
      cx = []
      ci = []
      cp = []

      # CSC format
      # https://www.gormanalysis.com/blog/sparse-matrix-storage-formats/
      cp << 0
      n.times do |j|
        (@data[j] || {}).sort_by { |k, v| k }.each do |k, v|
          cx << v
          ci << k
        end
        # cumulative column values
        cp << cx.size
      end

      {
        start: cp,
        index: ci,
        value: cx
      }
    end

    # private, for tests
    def nnz
      @data.sum { |_, v| v.count }
    end

    def initialize_copy(other)
      super
      @data = @data.transform_values(&:dup)
    end

    def self.from_dense(data)
      data = data.to_a
      m = data.size
      n = m > 0 ? data.first.size : 0

      mtx = Matrix.new(m, n)
      data.each_with_index do |row, i|
        raise ArgumentError, "row has different number of columns" if row.size != n
        row.each_with_index do |v, j|
          mtx[i, j] = v if v != 0
        end
      end
      mtx
    end
  end
end
