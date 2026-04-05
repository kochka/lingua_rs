# Changelog

## 0.4.0

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
