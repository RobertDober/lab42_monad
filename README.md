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


  Except the last case above the `interact` method returns
  either `[:ok, result]` or `[:error, message]` itself

This is much simpler than it seems, as some examples will show

#### Examples

Given an echo server
```ruby
    let(:content) { %w[Alpha Beta] }
    let(:echo_server) { ->(lines) { [:stdout, lines] } }
```
Then interacting with the server will echo `stdin` to `stdout`
```ruby
    expect($stdin).to receive(:readlines).with(chomp: true).and_return(content)
    expect($stdout).to receive(:puts).with(content)

    expect(Lab42::Monad.interact(echo_server))
      .to eq([:ok, content])
```

And we can also do this by reading `stdin` lazily
```ruby
    lazy_echo_server = ->(reader) { reader.to_a }
    lazy_input = StringIO.new(content.join("\n")).each_line(chomp: true)

    expect($stdin).to receive(:each_line).with(chomp: true).and_return(lazy_input)
    expect($stdout).to receive(:puts).with(content)

    Lab42::Monad.interact(echo_server, stdin: :lazy)
```

And we can also just put something to `stdout` **only**
```ruby
    message = %w[Hello World]
    expect($stdin).not_to receive(:readlines)
    expect($stdout).to receive(:puts).with(message)

    greeter = -> { [:stdout, message] }
    Lab42::Monad.interact(greeter, stdin: false)
```

And the same holds for `stdin` **only**
```ruby
    expect($stdin).to receive(:readlines).with(chomp: true).and_return(content)
    expect($stdout).not_to receive(:puts)

    reader = ->(lines) { lines }
    expect(Lab42::Monad.interact(reader, stdout: false)).to eq(content)
```

And this could degenerate into a NOP (useful for some parameterized code):
```ruby
    doubler = ->(number) { number * 2 }
    expect(Lab42::Monad.interact(doubler, 21, stdin: false, stdout: false)).to eq(42)
```

#### Error Handling

##### If the entity does not respect the result contract

Given this bad entity
```ruby
    let(:bad_entity) { ->(lines) { lines } }
```

Then `interact` will raise a Lab42::Monad::ContractViolation
```ruby
    expect($stdin).to receive(:readlines).with(chomp: true)

    expect { Lab42::Monad.interact(bad_entity) }
      .to raise_error(Lab42::Monad::ContractViolation)
```

##### If the entity wants to report some error

Then we will write to `stderr` and return an `:error` tuple
```ruby
    error_handler = -> { [:stderr, "that was bad"] }

    expect($stdin).not_to receive(:each_line)
    expect($stdin).not_to receive(:readlines)
    expect($stdout).not_to receive(:puts)

    expect($stderr).to receive(:puts).with("that was bad")

    expect(Lab42::Monad.interact(error_handler, stdin: false))
      .to eq([:error, "that was bad"])

```

## LICENSE

Copyright 2022 Robert Dober robert.dober@gmail.com,

Apache-2.0 [c.f LICENSE](LICENSE)
