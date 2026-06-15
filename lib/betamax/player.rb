module Betamax
  class Player
    attr_reader :tape, :root_proxy, :tapes_folder

    def initialize example, tapes_folder:
      @example = example
      @tapes_folder = tapes_folder
      @tape = Tape.from_rspec_example(example, tapes_folder:)
      @root_proxy = nil
    end

    def play
      insert_tape
      @example.run
      eject_tape unless @example.exception
    end

    def record object
      recorder = if @tape.exists?
                   MethodPlayer.new recording: @tape.recording
                 else
                   MethodRecorder.new object:, recording: @tape.recording
                 end

      @root_proxy = RecordedObject.new object:, recorder:
    end

    private

    def insert_tape
      @tape.load
      Fiber[:betamax_player] = self
    end

    def eject_tape
      Fiber[:betamax_player] = nil

      if @tape.exists?
        verify_fully_consumed!
      elsif @root_proxy
        @tape.save @root_proxy
      end
    end

    def verify_fully_consumed!
      return unless @root_proxy

      recorder = @root_proxy._betamax_recorder
      return if recorder.fully_consumed?

      raise Errors::UnusedRecordings, recorder.unused_recordings
    end
  end
end
