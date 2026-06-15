module Betamax
  class MethodPlayer
    attr_reader :recording

    def initialize recording:
      @recording = recording
      @playback_index = 0
    end

    def fully_consumed?
      @playback_index == @recording.size &&
        @recording.all? { |record| nested_fully_consumed? record }
    end

    def unused_recordings
      unused = @recording[@playback_index..] || []
      nested_unused = @recording.first(@playback_index).flat_map do |record|
        unused_from_record record
      end
      unused + nested_unused
    end

    def call(method_name, *args, **kwargs, &)
      record = advance_playback! method_name

      validate_method_name! record.method_name, method_name
      validate_args! method_name, args, record.args
      validate_kwargs! method_name, kwargs, record.kwargs
      validate_block! method_name, block_given?, record.block_given

      replay_yieldings(record.block_yieldings, &)

      record.result
    end

    private

    def nested_fully_consumed? record
      consumed?(record.result) &&
        record.block_yieldings.all? { |yielding| yielding_consumed? yielding }
    end

    def yielding_consumed? yielding
      yielding.args.all? { |arg| consumed? arg } &&
        yielding.kwargs.values.all? { |value| consumed? value }
    end

    def consumed? object
      return true unless object.instance_of? RecordedObject

      object._betamax_recorder.fully_consumed?
    end

    def unused_from_record record
      result_unused = unused_from_object record.result
      yielding_unused = record.block_yieldings.flat_map do |yielding|
        unused_from_yielding yielding
      end
      result_unused + yielding_unused
    end

    def unused_from_yielding yielding
      args_unused = yielding.args.flat_map { |arg| unused_from_object arg }
      kwargs_unused = yielding.kwargs.values.flat_map { |value| unused_from_object value }
      args_unused + kwargs_unused
    end

    def unused_from_object object
      return [] unless object.instance_of? RecordedObject

      object._betamax_recorder.unused_recordings
    end

    def replay_yieldings block_yieldings
      block_yieldings.each do |yielding|
        yield(*yielding.args, **yielding.kwargs)
      end
    end

    def advance_playback! method_name
      @recording[@playback_index].tap do |record|
        raise Errors::PlaybackFinished, method_name if record.nil?

        @playback_index += 1
      end
    end

    def validate_method_name! expected, actual
      return if expected == actual

      raise Errors::MethodMismatch.new expected:, actual:
    end

    def validate_args! method_name, actual_args, expected_args
      max_size = [actual_args.size, expected_args.size].max
      max_size.times do |i|
        actual = actual_args[i]
        expected = expected_args[i]
        next if actual == expected

        raise Errors::ArgumentMismatch.new method_name, expected:, actual:
      end
    end

    def validate_kwargs! method_name, actual_kwargs, expected_kwargs
      all_keys = (actual_kwargs.keys | expected_kwargs.keys)
      all_keys.each do |key|
        actual_value = actual_kwargs[key]
        expected_value = expected_kwargs[key]
        next if actual_value == expected_value

        raise Errors::KeywordArgumentMismatch.new method_name,
                                                  expected_key: key, expected_value:,
                                                  actual_key: key, actual_value:
      end
    end

    def validate_block! method_name, actual_block_given, expected_block_given
      raise Errors::BlockExpected, method_name if expected_block_given && !actual_block_given
      raise Errors::UnexpectedBlock, method_name if actual_block_given && !expected_block_given
    end
  end
end
