# frozen_string_literal: true

require_relative 'monad/interact'
module Lab42
  module Monad
    VERSION = "0.1.2"
    def self.interact(interactor, *args, **kwds)
      { stdin: true, stdout: true }.merge(kwds) => { stdin:, stdout: }
      Interact
        .new(args:, kwds:, stdin:, stdout:)
        .run(interactor)
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
