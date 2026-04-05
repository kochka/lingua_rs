# frozen_string_literal: true

require_relative 'lib/lingua/version'

Gem::Specification.new do |spec|
  spec.name = 'lingua_rs'
  spec.version = Lingua::VERSION
  spec.authors = ['Sébastien Vrillaud']
  spec.email = ['kochka@gmail.com']

  spec.summary = 'Fast language detection for Ruby, powered by Lingua (Rust).'
  spec.description = 'Native Ruby bindings for the Lingua Rust library. ' \
                     'Detects languages with confidence scores, ISO 639-1/639-3 support, ' \
                     'and configurable accuracy modes.'
  spec.homepage = 'https://github.com/kochka/lingua_rs'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata = {
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/blob/main/CHANGELOG.md",
    'documentation_uri' => "#{spec.homepage}#readme",
    'bug_tracker_uri' => "#{spec.homepage}/issues"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        %w[Cargo.toml Cargo.lock].include?(f) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github/ .gitlab-ci.yml .rubocop Gemfile CHANGELOG])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions = ['ext/lingua/extconf.rb']

  spec.add_dependency 'rb_sys', '~> 0.9.126'
  spec.add_development_dependency 'rake-compiler', '~> 1.3.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
