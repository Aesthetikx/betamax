module Betamax
  RecordedMethod = Data.define :method_name, :args, :kwargs, :block_given, :block_yieldings, :result

  # Implement YAML serialization / deserialization
  RecordedMethod.include Module.new {
    def init_with coder
      initialize **coder.map
    end

    def encode_with coder
      coder.map = to_h
    end
  }
end
