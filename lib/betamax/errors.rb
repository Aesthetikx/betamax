module Betamax
  module Errors
    class Error < StandardError; end

    class NoTapeInserted < Error
      def initialize message = "No tape inserted"
        super
      end
    end

    class PlaybackError < Error; end

    class PlaybackFinished < PlaybackError
      def initialize method_name
        super "Received #{method_name} but playback has finished"
      end
    end

    class MethodMismatch < PlaybackError
      def initialize expected:, actual:
        super "Expected method #{expected} but received #{actual}"
      end
    end

    class UnexpectedBlock < PlaybackError
      def initialize method_name
        super "Method #{method_name} was called with a block but was recorded without one"
      end
    end

    class BlockExpected < PlaybackError
      def initialize method_name
        super "Method #{method_name} was called without a block but was recorded with one"
      end
    end

    class ArgumentMismatch < PlaybackError
      def initialize method_name, expected:, actual:
        super "Method #{method_name} argument mismatch: " \
              "expected #{expected.inspect}, got #{actual.inspect}"
      end
    end

    class KeywordArgumentMismatch < PlaybackError
      def initialize method_name, expected_key:, expected_value:, actual_key:, actual_value:
        super "Method #{method_name} keyword argument mismatch: " \
              "expected #{expected_key}: #{expected_value.inspect}, " \
              "got #{actual_key}: #{actual_value.inspect}"
      end
    end

    class UnusedRecordings < PlaybackError
      def initialize unused_methods
        method_names = unused_methods.map(&:method_name).join(", ")
        super "Recording has #{unused_methods.size} unused method(s): #{method_names}"
      end
    end
  end
end
