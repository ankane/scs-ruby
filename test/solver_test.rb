require_relative "test_helper"

class SolverTest < Minitest::Test
  def test_version
    assert_match(/\A\d+\.\d+\.\d+\z/, SCS.lib_version)
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

  def test_matrix
    data = {
      p: SCS::Matrix.from_dense([[3, -1], [-1, 2]]),
      a: SCS::Matrix.from_dense([[-1, 1], [1, 0], [0, 1]]),
      b: [-1, 0.3, -0.5],
      c: [-1, -1]
    }
    cone = {z: 1, l: 2}

    solver = SCS::Solver.new
    result = solver.solve(data, cone, eps_abs: 1e-9, eps_rel: 1e-9, verbose: false)
    assert_in_delta 1.235, result[:pobj]
    assert_elements_in_delta [0.3, -0.7], result[:x]
    assert_elements_in_delta [2.7, 2.1, 0], result[:y]
  end

  def test_numo
    skip if ["jruby", "truffleruby"].include?(RUBY_ENGINE)

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
