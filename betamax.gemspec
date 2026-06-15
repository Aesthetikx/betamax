require_relative "lib/betamax/version"

Gem::Specification.new do |spec|
  spec.name = "betamax"
  spec.version = Betamax::VERSION
  spec.authors = ["John DeSilva"]
  spec.email = ["john@aesthetikx.info"]

  spec.summary = "Record and playback of arbitrary Ruby objects"
  spec.description = "Betamax allows for the recording and playback of arbitrary Ruby objects to simplify testing external dependencies" # rubocop:disable Layout/LineLength
  spec.homepage = "https://github.com/Aesthetikx/betamax"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Aesthetikx/betamax"
  spec.metadata["changelog_uri"] = "https://github.com/Aesthetikx/betamax/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename __FILE__
  spec.files = IO.popen %w[git ls-files -z], chdir: __dir__, err: IO::NULL do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename f }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://guides.rubygems.org/make-your-own-gem/
end
