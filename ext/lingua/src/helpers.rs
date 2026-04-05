use std::str::FromStr;
use std::cell::Cell;

use lingua::{IsoCode639_1, IsoCode639_3, Language};
use magnus::{ExceptionClass, Error, RModule, Ruby, Symbol, prelude::*};

thread_local! {
    static UNKNOWN_LANGUAGE_ERROR: Cell<Option<ExceptionClass>> = const { Cell::new(None) };
}

pub fn define_errors(module: &RModule) -> Result<(), Error> {
    let ruby = Ruby::get().unwrap();
    let class = module.define_error("UnknownLanguageError", ruby.exception_arg_error())?;
    UNKNOWN_LANGUAGE_ERROR.set(Some(class));
    Ok(())
}

pub fn unknown_language_error(ruby: &Ruby) -> ExceptionClass {
    UNKNOWN_LANGUAGE_ERROR.get().unwrap_or_else(|| ruby.exception_arg_error())
}

pub fn parse_language(input: &str) -> Option<Language> {
    Language::from_str(input)
        .ok()
        .or_else(|| {
            IsoCode639_1::from_str(input)
                .ok()
                .map(|code| Language::from_iso_code_639_1(&code))
        })
        .or_else(|| {
            IsoCode639_3::from_str(input)
                .ok()
                .map(|code| Language::from_iso_code_639_3(&code))
        })
}

pub fn fetch_option<T>(ruby: &Ruby, hash: &magnus::RHash, key: &str) -> Option<T>
where
    T: magnus::TryConvert,
{
    hash.fetch::<Symbol, T>(ruby.to_symbol(key))
        .or_else(|_| hash.fetch::<&str, T>(key))
        .ok()
}

pub fn value_to_string(value: magnus::Value) -> Result<String, Error> {
    String::try_convert(value).or_else(|_| {
        let ruby = Ruby::get().unwrap();
        let sym: Symbol = magnus::TryConvert::try_convert(value)?;
        Ok(sym
            .name()
            .map_err(|e| Error::new(ruby.exception_arg_error(), e.to_string()))?
            .to_string())
    })
}

#[cfg(test)]
mod tests {
    use super::parse_language;
    use lingua::Language;

    #[test]
    fn test_parse_language_by_name() {
        assert_eq!(parse_language("French"), Some(Language::French));
        assert_eq!(parse_language("English"), Some(Language::English));
        assert_eq!(parse_language("German"), Some(Language::German));
    }

    #[test]
    fn test_parse_language_by_iso6391() {
        assert_eq!(parse_language("fr"), Some(Language::French));
        assert_eq!(parse_language("en"), Some(Language::English));
        assert_eq!(parse_language("de"), Some(Language::German));
    }

    #[test]
    fn test_parse_language_by_iso6393() {
        assert_eq!(parse_language("fra"), Some(Language::French));
        assert_eq!(parse_language("eng"), Some(Language::English));
        assert_eq!(parse_language("deu"), Some(Language::German));
    }

    #[test]
    fn test_parse_language_case_insensitive() {
        assert_eq!(parse_language("french"), Some(Language::French));
        assert_eq!(parse_language("FR"), Some(Language::French));
        assert_eq!(parse_language("FRA"), Some(Language::French));
    }

    #[test]
    fn test_parse_language_invalid() {
        assert!(parse_language("").is_none());
        assert!(parse_language("xx").is_none());
        assert!(parse_language("notacode").is_none());
    }
}
