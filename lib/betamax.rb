require "pathname"

require_relative "betamax/errors"
require_relative "betamax/method_player"
require_relative "betamax/method_recorder"
require_relative "betamax/player"
require_relative "betamax/recorded_method"
require_relative "betamax/recorded_object"
require_relative "betamax/recorded_yielding"
require_relative "betamax/recording"
require_relative "betamax/rspec"
require_relative "betamax/tape"
require_relative "betamax/version"

module Betamax
  extend RSpec

  module_function

  def record object
    player = current_player

    raise Errors::NoTapeInserted unless player

    player.record object
  end

  def current_player
    Fiber[:betamax_player]
  end
end

Betamax.install_rspec! if defined? RSpec
