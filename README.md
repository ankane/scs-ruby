# SCS

[SCS](https://github.com/cvxgrp/scs) - the splitting conic solver - for Ruby

:fire: Supports many different [problem types](https://www.cvxpy.org/tutorial/advanced/index.html#choosing-a-solver)

[![Build Status](https://travis-ci.org/ankane/scs.svg?branch=master)](https://travis-ci.org/ankane/scs)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'scs'
```

## Getting Started

Prep the problem

```ruby
data = {a: [[1], [-1]], b: [1, 0], c: [-1]}
cone = {q: [], l: 2}
```

And solve it

```ruby
solver = SCS::Solver.new
solver.solve(data, cone)
```

## Settings

Default values shown

```ruby
solver.solve(data, cone, {
  normalize: true,            # heuristic data rescaling
  scale: 1.0,                 # if normalized, rescales by this factor
  rho_x: 1e-3,                # x equality constraint scaling
  max_iters: 5000,            # maximum iterations to take
  eps: 1e-5,                  # convergence tolerance
  alpha: 1.5,                 # relaxation parameter
  cg_rate: 2.0,               # for indirect, tolerance goes down like (1/iter)^cg_rate
  verbose: true,              # write out progress
  warm_start: false,          # warm start
  acceleration_lookback: 10,  # memory for acceleration
  write_data_filename: nil    # filename to write data if set
})
```

## Direct vs Indirect

SCS comes with two solvers: a direct solver which uses a cached LDL factorization and an indirect solver based on conjugate gradients. For the indirect solver, use:

```ruby
SCS::Solver.new(indirect: true)
```

## Resources

- [Conic Optimization via Operator Splitting and Homogeneous Self-Dual Embedding](https://web.stanford.edu/~boyd/papers/scs.html)

## History

View the [changelog](https://github.com/ankane/scs/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/scs/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/scs/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone --recursive https://github.com/ankane/scs.git
cd scs
bundle install
bundle exec rake compile
bundle exec rake test
```
