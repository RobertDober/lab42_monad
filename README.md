[![Issue Count](https://codeclimate.com/github/RobertDober/lab42_monad/badges/issue_count.svg)](https://codeclimate.com/github/RobertDober/lab42_monad)
[![CI](https://github.com/robertdober/lab42_monad/workflows/CI/badge.svg)](https://github.com/robertdober/lab42_monad/actions)
[![Coverage Status](https://coveralls.io/repos/github/RobertDober/lab42_monad/badge.svg?branch=master)](https://coveralls.io/github/RobertDober/lab42_monad?branch=master)
[![Gem Version](https://badge.fury.io/rb/lab42_monad.svg)](http://badge.fury.io/rb/lab42_monad)
[![Gem Downloads](https://img.shields.io/gem/dt/lab42_monad.svg)](https://rubygems.org/gems/lab42_monad)

# lab42_monad

```ruby
  require 'lab42/monad'
  Lab42::Monad::VERSION
```

# Simple Monadic Behaviors for Ruby

Implements only some simple monadic patterns right now, à la `IO.interact`

## How does it work?

Let us [speculate about](https://github.com/RobertDober/speculate_about) that:

### Context `Lab42::Monad.interact`

#### Synopsis:

This allows entities which want to manipulate `$stin` and/or `$stdout` to do
so in a pure, functional way by _delegating_ all io to the `interact` method

This works as follows

  - Define a `call` method on the entity, the needed interface depends on the
    call of `interact`

  - call `interact` with the entity, and an arbitrary argument list but with two
    special flags `stdin:` and `stdout:`, both defauling to `true`

  - depending on the flags: `interact` will _call_ the entity back with
    the keyword argument `stdin:` depending on the value of the passed in
    `stdin:` argument
      - falsy -> nil
      - true  -> `$stdin.readlines(chomp: true)`
      - :lazy -> a lazy enumerator reading `$stdin` (still with `chomp: true`)
    and all other arguments are passed through verbatim

    if the flag `stdout:` was set `interact` expects the result to be
      - truthy -> [:stderr|:stdout, result] and puts result to the corresponding output stream
      - falsey  -> anything and anything is returned


## LICENSE

Copyright 2022 Robert Dober robert.dober@gmail.com,

Apache-2.0 [c.f LICENSE](LICENSE)
