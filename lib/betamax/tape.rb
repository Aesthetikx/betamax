require "fileutils"
require "yaml"

module Betamax
  class Tape
    PERMITTED_YAML_CLASSES = [
      Betamax::Recording,
      Betamax::RecordedObject,
      Betamax::RecordedMethod,
      Betamax::RecordedYielding,
      Symbol
    ].freeze

    attr_reader :path, :recording

    def initialize path
      @path = Pathname.new path
      @recording = nil
    end

    def self.from_rspec_example example, tapes_folder:
      name = cassette_name_for example.metadata
      name.gsub! "::", "_"
      name.gsub!(/[\s-]+/, "_")
      name.gsub! %r{[^a-zA-Z0-9_/]}, ""

      filename = Pathname.new(name).sub_ext ".yaml"
      full_path = tapes_folder / filename

      new full_path
    end

    def self.cassette_name_for metadata
      # Build name from example group hierarchy + example description
      description_parts = []

      # Add the example description first
      description_parts << metadata[:description] if metadata[:description]

      # Walk up the example group hierarchy
      current = metadata[:example_group]
      while current
        description_parts.unshift current[:description] if current[:description]
        current = current[:parent_example_group]
      end

      description_parts.join "/"
    end

    def load
      FileUtils.mkdir_p @path.dirname

      if exists?
        load_existing_recording
      else
        prepare_new_recording
      end

      self
    end

    def save proxy
      return if exists? # Don't overwrite existing recordings

      recording = Betamax::Recording.new \
        version: Recording::VERSION,
        objects: { default: proxy }

      File.open @path, "w" do |file|
        file.puts recording.to_yaml
      end
    end

    def exists?
      File.exist? @path
    end

    private

    def load_existing_recording
      raw = YAML.safe_load_file @path, permitted_classes: PERMITTED_YAML_CLASSES
      @recording = raw.default_recording
    end

    def prepare_new_recording
      @recording = []
    end
  end
end
