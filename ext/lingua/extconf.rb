# frozen_string_literal: true

require 'mkmf'
require 'rb_sys/mkmf'

# Allow users to select specific languages to reduce binary size.
# Example: LINGUA_LANGUAGES=french,english,german bundle install
languages = ENV.fetch('LINGUA_LANGUAGES', '').split(',').map { |lang| lang.strip.downcase }

create_rust_makefile('lingua/lingua') do |r|
  unless languages.empty?
    r.extra_cargo_args << '--no-default-features'
    r.features = languages
  end
end
