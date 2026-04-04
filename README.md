# LinguaRs

[![CI](https://github.com/kochka/lingua_rs/actions/workflows/ci.yml/badge.svg)](https://github.com/kochka/lingua_rs/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/lingua_rs.svg)](https://badge.fury.io/rb/lingua_rs)
[![Downloads](https://img.shields.io/gem/dt/lingua_rs)](https://rubygems.org/gems/lingua_rs)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Ruby gem wrapping the [Lingua](https://github.com/pemistahl/lingua-rs) Rust library for language detection.

## Installation

Add the gem with Bundler:

```bash
bundle add lingua_rs --require=lingua
```

Or add it to your Gemfile manually:

```ruby
gem 'lingua_rs', require: 'lingua'
```

Then run `bundle install`.

### Build requirements

A Rust toolchain is required to compile the native extension. `rb-sys` currently depends on `bindgen 0.69` which does not support LLVM 22+. If your system uses LLVM 22+, point to LLVM 21:

```bash
export LIBCLANG_PATH=/usr/lib/llvm21/lib
export PATH=/usr/lib/llvm21/bin:$PATH
```

## Usage

### Basic detection

`Lingua.detect` takes a string and returns a `Lingua::Language` object, or `nil` if the language could not be determined.

```ruby
require 'lingua'

lang = Lingua.detect('Bonjour le monde')
lang.to_s       # => 'French'
lang.to_sym     # => :french
lang.to_iso     # => 'fr'
lang.to_iso6391 # => 'fr'
lang.to_iso6393 # => 'fra'
lang.inspect    # => '#<Lingua::Language French>'

Lingua.detect('') # => nil
```

### Restricting languages

Pass a `languages` option to limit detection to a subset of languages. Values can be full names, ISO 639-1 codes, or ISO 639-3 codes, and can be mixed freely.

```ruby
# By full name
Lingua.detect('Bonjour', languages: %w[English French German])

# By ISO 639-1 code
Lingua.detect('Bonjour', languages: %w[en fr de])

# By ISO 639-3 code
Lingua.detect('Bonjour', languages: %w[eng fra deu])

# Mixed
Lingua.detect('Bonjour', languages: %w[en french deu])
```

### Options

All options accept both symbol and string keys.

| Option | Type | Description |
|---|---|---|
| `languages` | `Array<String>` | Restrict detection to these languages (names, ISO 639-1 or ISO 639-3 codes) |
| `minimum_relative_distance` | `Float` | Minimum distance between the two top candidates (0.0 to 0.99). Higher values yield fewer but more confident results. |
| `is_low_accuracy_mode_enabled` | `Boolean` | Enable low accuracy mode for faster detection with reduced precision. |

```ruby
Lingua.detect 'Bonjour le monde',
              languages: %w[en fr],
              minimum_relative_distance: 0.9,
              is_low_accuracy_mode_enabled: true
```

### Persistent detector

`Lingua::Detector` builds the detector once and reuses it across calls, which is more efficient for repeated detection. It accepts the same options as the functional API, plus `is_every_language_model_preloaded` to eagerly load all language models into memory.

```ruby
detector = Lingua::Detector.new(
  languages: %w[en fr de],
  minimum_relative_distance: 0.1,
  is_low_accuracy_mode_enabled: true,
  is_every_language_model_preloaded: true
)

detector.detect('Bonjour le monde')   # => #<Lingua::Language French>
detector.detect('Hello world')        # => #<Lingua::Language English>
```

### Confidence

`confidence` returns the score (0.0 to 1.0) for a specific language. `confidence_values` returns an array of `Lingua::ConfidenceResult` objects sorted by confidence (highest first). Both are available on `Lingua::Detector` and as module methods on `Lingua`.

```ruby
detector.confidence('Bonjour le monde', :fr)  # => 0.8217
Lingua.confidence('Bonjour le monde', 'fr')   # => 0.8217

results = detector.confidence_values('Bonjour le monde')
results.first.language   # => #<Lingua::Language French>
results.first.confidence # => 0.8217
results.first.to_s       # => "French (0.82)"
results.sum(&:confidence) # => 1.0
```

### `Lingua::Language` methods

`Lingua::Language` objects support equality (`==`) and can be used as Hash keys.

| Method | Return type | Example |
|---|---|---|
| `to_s` | `String` | `'French'` |
| `to_sym` | `Symbol` | `:french` |
| `to_iso` | `String` | `'fr'` (alias for `to_iso6391`) |
| `to_iso6391` | `String` | `'fr'` |
| `to_iso6393` | `String` | `'fra'` |
| `inspect` | `String` | `'#<Lingua::Language French>'` |
| `==` | `Boolean` | Compare two languages |
| `hash` | `Integer` | Hash value (usable as Hash key) |

### `Lingua::ConfidenceResult` methods

Returned by `confidence_values`.

| Method | Return type | Example |
|---|---|---|
| `language` | `Lingua::Language` | `#<Lingua::Language French>` |
| `confidence` | `Float` | `0.8217` |
| `to_s` | `String` | `'French (0.82)'` |
| `inspect` | `String` | `'#<Lingua::ConfidenceResult French (0.8217)>'` |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake compile` to build the native extension and `rake test` to run the tests.

## Acknowledgements

This gem is built on top of [Lingua](https://github.com/pemistahl/lingua-rs) by [Peter M. Stahl](https://github.com/pemistahl), a highly accurate natural language detection library written in Rust.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
