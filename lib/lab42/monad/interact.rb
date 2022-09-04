# frozen_string_literal: true

require_relative 'contract_violation'
module Lab42
  module Monad
    class Interact
      def run(interactor)
        result = _run_stdin(interactor)

        if stdout
          _interact(result)
        else
          result
        end
      end

      private

      attr_reader :args, :kwds, :stdin, :stdout

      def initialize(args:, kwds:, stdin:, stdout:)
        @args   = args
        @kwds   = kwds.delete_if { [:stdin, :stdout].include?(_1) }
        # WANT:
        @stdin  = stdin
        @stdout = stdout
      end

      def _interact(result)
        case result
        in [:stdout, r]
          $stdout.puts r
          [:ok, r]
        in [:stderr, r]
          $stderr.puts r
          [:error, r]
        else
          raise ContractViolation, "result is not of the required format [:stdout|:stderr, value] but:\n\n#{result.inspect}"
        end
      end

      def _run_stdin(interactor)
        case stdin
        when true
          interactor.($stdin.readlines(chomp: true), *args, **kwds)
        when :lazy
          interactor.($stdin.each_line(chomp: true), *args, **kwds)
        else
          interactor.(*args, **kwds)
        end
      end
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
