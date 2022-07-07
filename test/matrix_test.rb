require_relative "test_helper"

class MatrixTest < Minitest::Test
  def test_row_index_out_of_bounds
    a = SCS::Matrix.new(2, 1)

    error = assert_raises(IndexError) do
      a[-1, 0] = 1
    end
    assert_equal "row index out of bounds", error.message

    2.times do |i|
      a[i, 0] = 1
    end

    error = assert_raises(IndexError) do
      a[2, 0] = 1
    end
    assert_equal "row index out of bounds", error.message
  end

  def test_column_index_out_of_bounds
    a = SCS::Matrix.new(1, 2)

    error = assert_raises(IndexError) do
      a[0, -1] = 1
    end
    assert_equal "column index out of bounds", error.message

    2.times do |i|
      a[0, i] = 1
    end

    error = assert_raises(IndexError) do
      a[0, 2] = 1
    end
    assert_equal "column index out of bounds", error.message
  end

  def test_set_zero
    a = SCS::Matrix.new(1, 2)
    a[0, 0] = 1
    assert_equal 1, a.nnz
    a[0, 0] = 0
    assert_equal 0, a.nnz
  end

  def test_from_dense
    error = assert_raises(ArgumentError) do
      SCS::Matrix.from_dense([[1, 2], [3]])
    end
    assert_equal "row has different number of columns", error.message
  end
end
