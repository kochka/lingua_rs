use lingua::{LanguageDetector, LanguageDetectorBuilder};
use magnus::{Error, RArray, RHash, Ruby};

use crate::confidence_result::ConfidenceResult;
use crate::segment::Segment;
use crate::helpers::{fetch_option, parse_language, value_to_string};
use crate::language::WrappedLanguage;

pub fn compute_confidence(
    detector: &LanguageDetector,
    subject: String,
    language: magnus::Value,
) -> Result<f64, Error> {
    let ruby = Ruby::get().unwrap();
    let language_str = value_to_string(language)?;
    let lang = parse_language(&language_str).ok_or_else(|| {
        Error::new(
            ruby.exception_arg_error(),
            format!("unknown language: \"{language_str}\""),
        )
    })?;
    Ok(detector.compute_language_confidence(subject, lang))
}

pub fn compute_confidence_values(
    detector: &LanguageDetector,
    subject: String,
) -> Result<RArray, Error> {
    let ruby = Ruby::get().unwrap();
    let values = detector.compute_language_confidence_values(subject);
    let result = ruby.ary_new_capa(values.len());
    for (language, confidence) in values {
        result.push(ConfidenceResult {
            language,
            confidence,
        })?;
    }
    Ok(result)
}

#[magnus::wrap(class = "Lingua::Detector")]
pub struct RubyDetector {
    detector: LanguageDetector,
}

impl RubyDetector {
    pub fn new(ruby: &Ruby, args: &[magnus::Value]) -> Result<Self, Error> {
        let options: Option<RHash> = if args.is_empty() {
            None
        } else {
            Some(magnus::TryConvert::try_convert(args[0])?)
        };
        let detector = build_detector_from_options(ruby, options.as_ref())?;
        Ok(Self { detector })
    }

    pub fn detect(&self, subject: String) -> Option<WrappedLanguage> {
        self.detector
            .detect_language_of(subject)
            .map(WrappedLanguage)
    }

    pub fn confidence(&self, subject: String, language: magnus::Value) -> Result<f64, Error> {
        compute_confidence(&self.detector, subject, language)
    }

    pub fn confidence_values(&self, subject: String) -> Result<RArray, Error> {
        compute_confidence_values(&self.detector, subject)
    }

    pub fn detect_multiple(&self, subject: String) -> Result<RArray, Error> {
        compute_detect_multiple(&self.detector, &subject)
    }
}

pub fn compute_detect_multiple(
    detector: &LanguageDetector,
    subject: &str,
) -> Result<RArray, Error> {
    let ruby = Ruby::get().unwrap();
    let results = detector.detect_multiple_languages_of(subject);
    let array = ruby.ary_new_capa(results.len());
    for r in results {
        let text = subject[r.start_index()..r.end_index()].to_string();
        let start_index = subject[..r.start_index()].chars().count();
        let end_index = start_index + text.chars().count();
        array.push(Segment {
            language: r.language(),
            start_index,
            end_index,
            word_count: r.word_count(),
            text,
        })?;
    }
    Ok(array)
}

pub fn build_detector_from_options(
    ruby: &Ruby,
    options: Option<&RHash>,
) -> Result<LanguageDetector, Error> {
    let raw_languages = options.and_then(|opts| fetch_option::<Vec<String>>(ruby, opts, "languages"));

    let mut builder = if let Some(raw_languages) = raw_languages {
        let mut languages = Vec::with_capacity(raw_languages.len());
        for l in &raw_languages {
            let lang = parse_language(l).ok_or_else(|| {
                Error::new(
                    ruby.exception_arg_error(),
                    format!("unknown language: \"{l}\""),
                )
            })?;
            languages.push(lang);
        }
        LanguageDetectorBuilder::from_languages(&languages)
    } else {
        LanguageDetectorBuilder::from_all_languages()
    };

    if let Some(opts) = options {
        if let Some(dist) = fetch_option::<f64>(ruby, opts, "minimum_relative_distance") {
            builder.with_minimum_relative_distance(dist);
        }
        if fetch_option::<bool>(ruby, opts, "is_every_language_model_preloaded").unwrap_or(false) {
            builder.with_preloaded_language_models();
        }
        if fetch_option::<bool>(ruby, opts, "is_low_accuracy_mode_enabled").unwrap_or(false) {
            builder.with_low_accuracy_mode();
        }
    }

    Ok(builder.build())
}
