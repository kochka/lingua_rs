# Changelog

## 0.6.0

- Add `lingua` command-line tool for shell use (detection, confidences, multi-language, batch from file/stdin, JSON output)

## 0.5.0

- Add parallel batch methods on `Lingua::Detector`: `detect_batch`, `confidence_batch`, `confidence_values_batch`, `detect_multiple_batch`,

## 0.4.5

- Bump `bindgen` to 0.72 (adds LLVM 22+ support)
- Bump `rb-sys` crate to 0.9.126

## 0.4.3

- Add `--with-lingua-languages` build option for persistent language selection via `bundle config`

## 0.4.2

- Validate detector options to prevent panics that crash the Ruby process

## 0.4.1

- Add language predicate methods (`lang.french?`, `lang.fr?`, `lang.fra?`)
- Add `iso_code` alias for `to_iso6391`
- Add `Lingua::UnknownLanguageError` (subclass of `ArgumentError`) for invalid language inputs
- Add `LINGUA_LANGUAGES` env var to compile only selected languages and reduce binary size

## 0.3.0

- Add `Lingua::Language[]` lookup by name, ISO 639-1 or ISO 639-3 code
- Add `Lingua::Language.all`, `.names` and `.iso_codes` class methods

## 0.2.0

- Add `detect_multiple` for mixed-language text detection (`Lingua::Segment`)

## 0.1.0

- Initial release
