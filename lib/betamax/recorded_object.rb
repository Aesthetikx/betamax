module Betamax
  class RecordedObject
    attr_reader :_betamax_recorder

    def initialize object:, recorder:
      @_betamax_object = object
      @_betamax_recorder = recorder
    end

    def respond_to_missing? method_name, _include_private = false
      @_betamax_object.respond_to? method_name
    end

    def method_missing(...)
      @_betamax_recorder.call(...)
    end
  end

  # Implement YAML serialization / deserialization
  RecordedObject.include Module.new {
    def init_with coder
      recording = coder.map.fetch :recording
      recorder = MethodPlayer.new recording: recording
      initialize object: nil, recorder: recorder
    end

    def encode_with coder
      coder.map = {
        class_name: @_betamax_object.class.name,
        recording: @_betamax_recorder.recording
      }
    end
  }
end
