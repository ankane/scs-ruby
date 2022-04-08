# SCS Ruby

[SCS](https://github.com/cvxgrp/scs) - the splitting conic solver - for Ruby

:fire: Supports many different [problem types](https://www.cvxpy.org/tutorial/advanced/index.html#choosing-a-solver)

[![Build Status](https://github.com/ankane/scs-ruby/workflows/build/badge.svg?branch=master)](https://github.com/ankane/scs-ruby/actions)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem "scs"
```

If installation fails, you may need to install [dependencies](#dependencies).

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
solver.solve(data, cone,
  normalize: true,            # heuristic data rescaling
  scale: 0.1,                 # if normalized, rescales by this factor
  adaptive_scale: true,       # heuristically adapt dual scale through the solve
  rho_x: 1e-6,                # x equality constraint scaling
  max_iters: 1e5,             # maximum iterations to take
  eps_abs: 1e-4,              # absolute feasibility tolerance
  eps_rel: 1e-4,              # relative feasibility tolerance
  eps_infeas: 1e-7,           # infeasibility tolerance
  alpha: 1.5,                 # relaxation parameter
  time_limit_secs: nil,       # time limit for solve run in seconds
  verbose: true,              # write out progress
  warm_start: false,          # warm start
  acceleration_lookback: 10,  # memory for acceleration
  acceleration_interval: 10,  # iterations to run Anderson acceleration
  write_data_filename: nil,   # filename to write data if set
  log_csv_filename: nil       # write csv logs of various quantities
)
```

## Direct vs Indirect

SCS comes with two solvers: a direct solver which uses a cached LDL factorization and an indirect solver based on conjugate gradients. For the indirect solver, use:

```ruby
SCS::Solver.new(indirect: true)
```

## Dependencies

BLAS and LAPACK are required for SCS.

```sh
sudo apt-get install libblas-dev liblapack-dev
```

On Heroku, use the [heroku-apt-buildpack](https://github.com/heroku/heroku-buildpack-apt).

## Resources

- [Conic Optimization via Operator Splitting and Homogeneous Self-Dual Embedding](https://web.stanford.edu/~boyd/papers/scs.html)

## History

View the [changelog](https://github.com/ankane/scs-ruby/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/scs-ruby/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/scs-ruby/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone --recursive https://github.com/ankane/scs-ruby.git
cd scs-ruby
bundle install
bundle exec rake compile
bundle exec rake test
```
