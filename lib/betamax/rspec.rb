module Betamax
  module RSpec
    DEFAULT_TAPES_FOLDER = Pathname.new "spec/betamax_tapes/"

    def play_rspec example, tapes_folder: DEFAULT_TAPES_FOLDER
      Player.new(example, tapes_folder:).play
    end

    def install_rspec!
      ::RSpec.configure do |config|
        config.around :each, :betamax do |example|
          Betamax.play_rspec example
        end
      end
    end
  end
end
