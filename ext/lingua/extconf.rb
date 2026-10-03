# frozen_string_literal: true

require 'mkmf'
require 'rb_sys/mkmf'

# Allow users to select specific languages to reduce binary size.
# Supports both --with-lingua-languages build option and LINGUA_LANGUAGES env var.
# Example: bundle config set build.lingua_rs --with-lingua-languages=core
# Example: LINGUA_LANGUAGES=french,english,german bundle install
selection = with_config('lingua-languages', nil) || ENV.fetch('LINGUA_LANGUAGES', '')
languages = selection.to_s.split(',').map { |lang| lang.strip.downcase }.reject(&:empty?)

create_rust_makefile('lingua/lingua') do |r|
  # Cargo strips debuginfo from release builds by default. With rustc <= 1.98.0,
  # stripping leaves the LINKEDIT string pool misaligned and dyld on macOS 27+
  # refuses to load the bundle ("mis-aligned LINKEDIT string pool"), see
  # rust-lang/rust#157750. Can be removed once rustc >= 1.98.1 is the minimum.
  r.extra_rustflags << '-Cstrip=none' if RUBY_PLATFORM.include?('darwin')

  unless languages.empty?
    r.extra_cargo_args << '--no-default-features'
    r.features = languages
  end
end
