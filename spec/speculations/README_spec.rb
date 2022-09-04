# DO NOT EDIT!!!
# This file was generated from "README.md" with the speculate_about gem, if you modify this file
# one of two bad things will happen
# - your documentation specs are not correct
# - your modifications will be overwritten by the speculate rake task
# YOU HAVE BEEN WARNED
RSpec.describe "README.md" do
  # README.md:22
  context "`Lab42::Monad.interact`" do
    # README.md:58
    let(:content) { %w[Alpha Beta] }
    let(:echo_server) { ->(lines) { [:stdout, lines] } }
    # README.md:112
    let(:bad_entity) { ->(lines) { lines } }
    it "interacting with the server will echo `stdin` to `stdout` (README.md:63)" do
      expect($stdin).to receive(:readlines).with(chomp: true).and_return(content)
      expect($stdout).to receive(:puts).with(content)

      expect(Lab42::Monad.interact(echo_server))
      .to eq([:ok, content])
    end
    it "we can also do this by reading `stdin` lazily (README.md:72)" do
      lazy_echo_server = ->(reader) { reader.to_a }
      lazy_input = StringIO.new(content.join("\n")).each_line(chomp: true)

      expect($stdin).to receive(:each_line).with(chomp: true).and_return(lazy_input)
      expect($stdout).to receive(:puts).with(content)

      Lab42::Monad.interact(echo_server, stdin: :lazy)
    end
    it "we can also just put something to `stdout` **only** (README.md:83)" do
      message = %w[Hello World]
      expect($stdin).not_to receive(:readlines)
      expect($stdout).to receive(:puts).with(message)

      greeter = -> { [:stdout, message] }
      Lab42::Monad.interact(greeter, stdin: false)
    end
    it "the same holds for `stdin` **only** (README.md:93)" do
      expect($stdin).to receive(:readlines).with(chomp: true).and_return(content)
      expect($stdout).not_to receive(:puts)

      reader = ->(lines) { lines }
      expect(Lab42::Monad.interact(reader, stdout: false)).to eq(content)
    end
    it "this could degenerate into a NOP (useful for some parameterized code): (README.md:102)" do
      doubler = ->(number) { number * 2 }
      expect(Lab42::Monad.interact(doubler, 21, stdin: false, stdout: false)).to eq(42)
    end
    it "`interact` will raise a Lab42::Monad::ContractViolation (README.md:117)" do
      expect($stdin).to receive(:readlines).with(chomp: true)

      expect { Lab42::Monad.interact(bad_entity) }
      .to raise_error(Lab42::Monad::ContractViolation)
    end
    it "we will write to `stderr` and return an `:error` tuple (README.md:127)" do
      error_handler = -> { [:stderr, "that was bad"] }

      expect($stdin).not_to receive(:each_line)
      expect($stdin).not_to receive(:readlines)
      expect($stdout).not_to receive(:puts)

      expect($stderr).to receive(:puts).with("that was bad")

      expect(Lab42::Monad.interact(error_handler, stdin: false))
      .to eq([:error, "that was bad"])

    end
  end
end