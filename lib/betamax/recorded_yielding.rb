module Betamax
  RecordedYielding = Data.define :args, :kwargs

  # Implement YAML serialization / deserialization
  RecordedYielding.include Module.new {
    def init_with coder
      initialize **coder.map
    end

    def encode_with coder
      coder.map = to_h
    end
  }
end
