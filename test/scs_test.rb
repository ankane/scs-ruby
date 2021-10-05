require_relative "test_helper"

class SCSTest < Minitest::Test
  def test_version
    assert_equal "3.0.0", SCS.lib_version
  end

  def test_direct
    data = {a: [[1], [-1]], b: [1, 0], c: [-1]}
    cone = {q: [], l: 2}

    solver = SCS::Solver.new

    result = solver.solve(data, cone, verbose: false)
    assert_equal "solved", result[:status]
    assert_elements_in_delta [1], result[:x]
    assert_elements_in_delta [1, 0], result[:y]
    assert_elements_in_delta [0, 1], result[:s]

    new_cone = {q: [2], l: 0}
    result = solver.solve(data, new_cone, verbose: false)
    assert_elements_in_delta [0.5], result[:x]
    assert_elements_in_delta [0.5, -0.5], result[:y]
    assert_elements_in_delta [0.5, 0.5], result[:s]
  end

  def test_indirect
    data = {a: [[1], [-1]], b: [1, 0], c: [-1]}
    cone = {q: [], l: 2}

    solver = SCS::Solver.new(indirect: true)

    result = solver.solve(data, cone, verbose: false)
    assert_equal "solved", result[:status]
    assert_elements_in_delta [1], result[:x]
    assert_elements_in_delta [1, 0], result[:y]
    assert_elements_in_delta [0, 1], result[:s]

    new_cone = {q: [2], l: 0}
    result = solver.solve(data, new_cone, verbose: false)
    assert_elements_in_delta [0.5], result[:x]
    assert_elements_in_delta [0.5, -0.5], result[:y]
    assert_elements_in_delta [0.5, 0.5], result[:s]
  end

  def test_numo
    data = {
      a: Numo::NArray.cast([[1], [-1]]),
      b: Numo::NArray.cast([1, 0]),
      c: Numo::NArray.cast([-1])
    }
    cone = {q: Numo::NArray.cast([]), l: 2}

    solver = SCS::Solver.new

    result = solver.solve(data, cone, verbose: false)
    assert_equal "solved", result[:status]
    assert_elements_in_delta [1], result[:x]
    assert_elements_in_delta [1, 0], result[:y]
    assert_elements_in_delta [0, 1], result[:s]

    new_cone = {q: Numo::NArray.cast([2]), l: 0}
    result = solver.solve(data, new_cone, verbose: false)
    assert_elements_in_delta [0.5], result[:x]
    assert_elements_in_delta [0.5, -0.5], result[:y]
    assert_elements_in_delta [0.5, 0.5], result[:s]
  end
end
