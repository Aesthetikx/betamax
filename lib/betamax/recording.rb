module Betamax
  Recording = Data.define :version, :objects

  Recording::VERSION = 1.0

  # Implement YAML serialization / deserialization
  Recording.include Module.new {
    def init_with coder
      initialize **coder.map
    end

    def encode_with coder
      coder.map = to_h
    end

    def default_recording
      objects.fetch(:default)._betamax_recorder.recording
    end
  }
end
