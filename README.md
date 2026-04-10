# LinguaRs

[![CI](https://github.com/kochka/lingua_rs/actions/workflows/ci.yml/badge.svg)](https://github.com/kochka/lingua_rs/actions/workflows/ci.yml)
[![Gem Version](https://img.shields.io/gem/v/lingua_rs?color=cc342d)](https://rubygems.org/gems/lingua_rs)
[![Downloads](https://img.shields.io/gem/dt/lingua_rs?color=0969da)](https://rubygems.org/gems/lingua_rs)
[![License: MIT](https://img.shields.io/badge/License-MIT-6e7781.svg)](https://opensource.org/licenses/MIT)

Native Ruby bindings for the [Lingua](https://github.com/pemistahl/lingua-rs) Rust library, bringing highly accurate language detection for short text and mixed-language text, with confidence scores and ISO 639-1/639-3 language codes.

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

A Rust toolchain is required to compile the native extension.

## Usage

### Basic detection

`Lingua.detect` takes a string and returns a `Lingua::Language` object, or `nil` if the language could not be determined.

```ruby
require 'lingua'

lang = Lingua.detect('Bonjour le monde')
lang.french?    # => true
lang.to_s       # => 'French'
lang.to_sym     # => :french
lang.to_iso     # => 'fr'
lang.to_iso6393 # => 'fra'

Lingua.detect('') # => nil
```

### Restricting languages

Pass a `languages` option to limit detection to a subset of languages. Values can be full names, ISO 639-1 codes, or ISO 639-3 codes, and can be mixed freely. Restricting the candidate set is also faster, since the detector has fewer languages to compare against.

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

### Mixed-language detection

`detect_multiple` identifies multiple languages within a single text and returns an array of `Lingua::Segment` objects. Available on both `Lingua::Detector` and as a module method on `Lingua`.

```ruby
text = "Parlez-vous français? Ich spreche Französisch nur ein bisschen. A little bit is better than nothing."

segments = Lingua.detect_multiple(text, languages: %w[en fr de])
segments.each do |s|
  puts "#{s.language} (#{s.start_index}..#{s.end_index}): #{s.text}"
end
# French (0..22): Parlez-vous français?
# German (23..64): Ich spreche Französisch nur ein bisschen.
# English (65..101): A little bit is better than nothing.

# With a persistent detector
detector = Lingua::Detector.new(languages: %w[en fr de])
detector.detect_multiple(text)
```

### Parallel batch detection

`Lingua::Detector` provides batch methods that process multiple texts in parallel using [Rayon](https://github.com/rayon-rs/rayon). These are significantly faster than calling single-text methods in a loop.

```ruby
detector = Lingua::Detector.new(languages: %w[en fr de])

# Detect language of multiple texts
detector.detect_batch(['Bonjour le monde', 'Hello world', 'Hallo Welt'])
# => [#<Lingua::Language French>, #<Lingua::Language English>, #<Lingua::Language German>]

# Confidence for a specific language across multiple texts
detector.confidence_batch(['Bonjour le monde', 'Hello world'], :fr)
# => [0.8217, 0.0215]

# Confidence values for multiple texts
detector.confidence_values_batch(['Bonjour le monde', 'Hello world'])
# => [[#<Lingua::ConfidenceResult French (0.82)>, ...], [#<Lingua::ConfidenceResult English (0.91)>, ...]]

# Mixed-language detection on multiple texts
detector.detect_multiple_batch(['Bonjour le monde. Hello world.', 'Ich bin müde. Salut tout le monde.'])
# => [[#<Lingua::Segment French ...>, #<Lingua::Segment English ...>], [#<Lingua::Segment German ...>, #<Lingua::Segment French ...>]]
```

| Method | Return type | Description |
|---|---|---|
| `detect_batch(texts)` | `Array<Language\|nil>` | Detect language of each text |
| `detect_multiple_batch(texts)` | `Array<Array<Segment>>` | Mixed-language detection for each text |
| `confidence_values_batch(texts)` | `Array<Array<ConfidenceResult>>` | Confidence values for each text |
| `confidence_batch(texts, language)` | `Array<Float>` | Confidence for a specific language across texts |

### Error handling

`Lingua::UnknownLanguageError` (subclass of `ArgumentError`) is raised when an unrecognized language name or code is passed:

```ruby
begin
  Lingua.detect('Hello', languages: %w[en zzzz])
rescue Lingua::UnknownLanguageError => e
  puts e.message # => unknown language: "zzzz"
end
```

## API Reference

### `Lingua::Language`

`Lingua::Language` objects support equality (`==`) and can be used as Hash keys. You can look up a language by name, ISO 639-1 code, or ISO 639-3 code using `[]`:

```ruby
Lingua::Language['French']  # => #<Lingua::Language French>
Lingua::Language[:fr]       # => #<Lingua::Language French>
Lingua::Language['fra']     # => #<Lingua::Language French>
Lingua::Language['xxx']     # => nil
```

| Method | Return type | Description |
|---|---|---|
| `Lingua::Language.all` | `Array<Lingua::Language>` | All supported languages |
| `Lingua::Language.names` | `Array<String>` | All language names (e.g. `'French'`) |
| `Lingua::Language.iso_codes` | `Array<String>` | All ISO 639-1 codes (e.g. `'fr'`) |

| Method | Return type | Example |
|---|---|---|
| `name` | `String` | `'French'` |
| `to_s` | `String` | `'French'` (alias for `name`) |
| `to_sym` | `Symbol` | `:french` |
| `iso_code` | `String` | `'fr'` (alias for `to_iso6391`) |
| `to_iso` | `String` | `'fr'` (alias for `to_iso6391`) |
| `to_iso6391` | `String` | `'fr'` |
| `to_iso6393` | `String` | `'fra'` |
| `<name>?` | `Boolean` | Dynamic predicate for any language (`french?`, `fr?`, `fra?`) |
| `inspect` | `String` | `'#<Lingua::Language French>'` |
| `==` | `Boolean` | Compare two languages |
| `hash` | `Integer` | Hash value (usable as Hash key) |

### `Lingua::ConfidenceResult`

Returned by `confidence_values`.

| Method | Return type | Example |
|---|---|---|
| `language` | `Lingua::Language` | `#<Lingua::Language French>` |
| `confidence` | `Float` | `0.8217` |
| `to_s` | `String` | `'French (0.82)'` |
| `inspect` | `String` | `'#<Lingua::ConfidenceResult French (0.8217)>'` |

### `Lingua::Segment`

Returned by `detect_multiple`.

| Method | Return type | Example |
|---|---|---|
| `language` | `Lingua::Language` | `#<Lingua::Language French>` |
| `start_index` | `Integer` | `0` |
| `end_index` | `Integer` | `22` |
| `word_count` | `Integer` | `3` |
| `text` | `String` | `'Parlez-vous français? '` |
| `to_s` | `String` | `'French (0-22): Parlez-vous français? '` |
| `inspect` | `String` | `'#<Lingua::Segment French (0-22) "Parlez-vous français? ">'` |

## Optimization: selecting languages

By default, all 75 languages are compiled into the native extension (~278 MB). If you only need a subset, select languages at build time to reduce binary size and improve detection speed.

### Build option

Use `--with-lingua-languages` to select languages. With Bundler you can persist the setting so it applies to every future `bundle install`:

```bash
bundle config set build.lingua_rs --with-lingua-languages=core
bundle install
```

This compiles only the selected language models (~29 MB for the `core` bundle). You can use individual language names or predefined bundles, and you can mix both in the same build.

The setting is saved in your local Bundler config (`~/.bundle/config` or `.bundle/config`) and is reused automatically on subsequent installs. To change it later:

```bash
bundle config set build.lingua_rs --with-lingua-languages=europe_common,japanese
bundle install
```

To remove it and go back to all languages:

```bash
bundle config unset build.lingua_rs
bundle install
```

This also works with `gem install`:

```bash
gem install lingua_rs -- --with-lingua-languages=french,english,german
```


### Available languages and bundles

| Bundle | Languages |
| --- | --- |
| `core` | `english`, `french`, `german`, `spanish`, `italian`, `portuguese` |
| `europe_common` | `core` + `dutch`, `polish`, `russian`, `turkish` |
| `americas` | `english`, `spanish`, `portuguese`, `french` |
| `mena` | `arabic`, `turkish`, `persian`, `hebrew` |
| `south_asia` | `hindi`, `urdu`, `bengali`, `tamil`, `telugu`, `punjabi`, `marathi`, `gujarati` |
| `east_asia` | `chinese`, `japanese`, `korean`, `vietnamese`, `thai` |
| `africa_common` | `arabic`, `english`, `french`, `swahili`, `somali`, `yoruba`, `zulu` |

Examples:

```bash
bundle config set build.lingua_rs --with-lingua-languages=core
bundle config set build.lingua_rs --with-lingua-languages=europe_common,polish
bundle config set build.lingua_rs --with-lingua-languages=east_asia,english
```

Language and bundle names must match the Cargo features defined by this gem (lowercase, e.g. `french`, `english`, `german`, `core`, `europe_common`).

Supported languages (from [Lingua Rust's official list](https://github.com/pemistahl/lingua-rs?tab=readme-ov-file#3-which-languages-are-supported)):

`afrikaans`, `albanian`, `arabic`, `armenian`, `azerbaijani`, `basque`, `belarusian`, `bengali`, `bokmal`, `bosnian`, `bulgarian`, `catalan`, `chinese`, `croatian`, `czech`, `danish`, `dutch`, `english`, `esperanto`, `estonian`, `finnish`, `french`, `ganda`, `georgian`, `german`, `greek`, `gujarati`, `hebrew`, `hindi`, `hungarian`, `icelandic`, `indonesian`, `irish`, `italian`, `japanese`, `kazakh`, `korean`, `latin`, `latvian`, `lithuanian`, `macedonian`, `malay`, `maori`, `marathi`, `mongolian`, `nynorsk`, `persian`, `polish`, `portuguese`, `punjabi`, `romanian`, `russian`, `serbian`, `shona`, `slovak`, `slovene`, `somali`, `sotho`, `spanish`, `swahili`, `swedish`, `tagalog`, `tamil`, `telugu`, `thai`, `tsonga`, `tswana`, `turkish`, `ukrainian`, `urdu`, `vietnamese`, `welsh`, `xhosa`, `yoruba`, `zulu`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake compile` to build the native extension and `rake test` to run the tests.

To run benchmarks (sequential vs batch performance comparison): `rake bench`

## Acknowledgements

This gem is built on top of [Lingua](https://github.com/pemistahl/lingua-rs) by [Peter M. Stahl](https://github.com/pemistahl), a highly accurate natural language detection library written in Rust.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
