module Betamax
  class MethodRecorder
    PRIMITIVE_TYPES = [Integer, Float, String, Symbol, TrueClass, FalseClass, NilClass].freeze

    attr_reader :recording

    def initialize object:, recording: []
      @object = object
      @recording = recording
    end

    def call(method_name, *args, **kwargs, &) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      block_yieldings = []

      result = if block_given?
                 @object.send(method_name, *args, **kwargs) do |*block_args, **block_kwargs|
                   wrapped_args = block_args.map { |arg| wrap_object arg }
                   wrapped_kwargs = block_kwargs.transform_values { |value| wrap_object value }

                   yielding = RecordedYielding.new args: wrapped_args, kwargs: wrapped_kwargs
                   block_yieldings << yielding

                   yield(*wrapped_args, **wrapped_kwargs)
                 end
               else
                 @object.send(method_name, *args, **kwargs, &)
               end

      wrapped_result = wrap_object result

      @recording << RecordedMethod.new(
        method_name:,
        args:,
        kwargs:,
        block_given: block_given?,
        block_yieldings:,
        result: wrapped_result
      )

      wrapped_result
    end

    private

    def wrap_object object
      case object
      when *PRIMITIVE_TYPES
        object
      else
        recorder = MethodRecorder.new object:, recording: []
        RecordedObject.new object:, recorder:
      end
    end
  end
end
