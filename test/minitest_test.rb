require 'minitest/autorun'
require 'tmpdir'
require 'betamax'

class BetamaxMinitestTest < Minitest::Test
  include Betamax::Minitest

  class Runner
    def run command
      "output for #{command}"
    end
  end

  class RaisingRunner
    def run(*)
      raise 'the real object was called during playback'
    end
  end

  def test_records_then_replays
    Dir.mktmpdir do |directory|
      with_betamax(tapes_folder: directory) { Betamax.record(Runner.new).run 'task export' }

      assert_path_exists File.join(directory, 'BetamaxMinitestTest/test_records_then_replays.yaml')

      with_betamax tapes_folder: directory do
        assert_equal 'output for task export', Betamax.record(RaisingRunner.new).run('task export')
      end
    end
  end

  def test_clears_the_player_when_the_block_raises
    Dir.mktmpdir do |directory|
      assert_raises(RuntimeError) { with_betamax(tapes_folder: directory) { raise 'test failed' } }

      assert_nil Betamax.current_player
    end
  end
end
