module Betamax
  module Minitest
    DEFAULT_TAPES_FOLDER = Pathname.new 'test/betamax_tapes/'

    # Adapts a Minitest test and block to the example interface Player expects.
    class Example
      attr_reader :metadata

      def initialize test, &block
        @metadata = { description: test.name, example_group: { description: test.class.name } }
        @block = block
      end

      def run
        @block.call
      end

      def exception
        nil
      end
    end

    def with_betamax(tapes_folder: DEFAULT_TAPES_FOLDER, &)
      Player.new(Example.new(self, &), tapes_folder: Pathname.new(tapes_folder)).play
    end
  end
end
