mod confidence_result;
mod segment;
mod detector;
mod helpers;
mod language;

use magnus::{Error, RArray, RHash, Ruby, function, method, prelude::*};

use confidence_result::ConfidenceResult;
use segment::Segment;
use detector::{RubyDetector, build_detector_from_options, compute_confidence, compute_confidence_values, compute_detect_multiple};
use language::WrappedLanguage;

fn detect(ruby: &Ruby, arguments: RArray) -> Result<Option<WrappedLanguage>, Error> {
    let subject = arguments
        .shift::<String>()
        .map_err(|_| Error::new(ruby.exception_arg_error(), "expected a string as first argument"))?;
    let options = arguments.shift::<RHash>().ok();
    let detector = build_detector_from_options(ruby, options.as_ref())?;
    Ok(detector.detect_language_of(subject).map(WrappedLanguage))
}

fn confidence(ruby: &Ruby, subject: String, language: magnus::Value) -> Result<f64, Error> {
    let detector = build_detector_from_options(ruby, None)?;
    compute_confidence(&detector, subject, language)
}

fn confidence_values(ruby: &Ruby, arguments: RArray) -> Result<RArray, Error> {
    let subject = arguments
        .shift::<String>()
        .map_err(|_| Error::new(ruby.exception_arg_error(), "expected a string as first argument"))?;
    let options = arguments.shift::<RHash>().ok();
    let detector = build_detector_from_options(ruby, options.as_ref())?;
    compute_confidence_values(&detector, subject)
}

fn detect_multiple(ruby: &Ruby, arguments: RArray) -> Result<RArray, Error> {
    let subject = arguments
        .shift::<String>()
        .map_err(|_| Error::new(ruby.exception_arg_error(), "expected a string as first argument"))?;
    let options = arguments.shift::<RHash>().ok();
    let detector = build_detector_from_options(ruby, options.as_ref())?;
    compute_detect_multiple(&detector, &subject)
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("Lingua")?;

    // Lingua::Language
    let language_class = module.define_class("Language", ruby.class_object())?;
    language_class.undef_default_alloc_func();
    language_class.define_method("name", method!(WrappedLanguage::name, 0))?;
    language_class.define_method("to_s", method!(WrappedLanguage::name, 0))?;
    language_class.define_method("to_iso6391", method!(WrappedLanguage::to_iso6391, 0))?;
    language_class.define_method("to_iso", method!(WrappedLanguage::to_iso6391, 0))?;
    language_class.define_method("to_iso6393", method!(WrappedLanguage::to_iso6393, 0))?;
    language_class.define_method("to_sym", method!(WrappedLanguage::to_sym, 0))?;
    language_class.define_method("inspect", method!(WrappedLanguage::inspect, 0))?;
    language_class.define_method("==", method!(WrappedLanguage::eq, 1))?;
    language_class.define_method("eql?", method!(WrappedLanguage::eq, 1))?;
    language_class.define_method("hash", method!(WrappedLanguage::hash, 0))?;
    language_class.define_singleton_method("[]", function!(WrappedLanguage::lookup, 1))?;
    language_class.define_singleton_method("all", function!(WrappedLanguage::all, 0))?;
    language_class.define_singleton_method("names", function!(WrappedLanguage::names, 0))?;
    language_class.define_singleton_method("iso_codes", function!(WrappedLanguage::iso_codes, 0))?;

    // Lingua::ConfidenceResult
    let confidence_class = module.define_class("ConfidenceResult", ruby.class_object())?;
    confidence_class.undef_default_alloc_func();
    confidence_class.define_method("language", method!(ConfidenceResult::language, 0))?;
    confidence_class.define_method("confidence", method!(ConfidenceResult::confidence, 0))?;
    confidence_class.define_method("to_s", method!(ConfidenceResult::to_s, 0))?;
    confidence_class.define_method("inspect", method!(ConfidenceResult::inspect, 0))?;

    // Lingua::Segment
    let segment_class = module.define_class("Segment", ruby.class_object())?;
    segment_class.undef_default_alloc_func();
    segment_class.define_method("language", method!(Segment::language, 0))?;
    segment_class.define_method("start_index", method!(Segment::start_index, 0))?;
    segment_class.define_method("end_index", method!(Segment::end_index, 0))?;
    segment_class.define_method("word_count", method!(Segment::word_count, 0))?;
    segment_class.define_method("text", method!(Segment::text, 0))?;
    segment_class.define_method("to_s", method!(Segment::to_s, 0))?;
    segment_class.define_method("inspect", method!(Segment::inspect, 0))?;

    // Lingua::Detector
    let detector_class = module.define_class("Detector", ruby.class_object())?;
    detector_class.define_singleton_method("new", function!(RubyDetector::new, -1))?;
    detector_class.define_method("detect", method!(RubyDetector::detect, 1))?;
    detector_class.define_method("confidence", method!(RubyDetector::confidence, 2))?;
    detector_class.define_method("confidence_values", method!(RubyDetector::confidence_values, 1))?;
    detector_class.define_method("detect_multiple", method!(RubyDetector::detect_multiple, 1))?;

    // Functional API (module methods)
    module.define_singleton_method("detect", function!(detect, -2))?;
    module.define_singleton_method("confidence", function!(confidence, 2))?;
    module.define_singleton_method("confidence_values", function!(confidence_values, -2))?;
    module.define_singleton_method("detect_multiple", function!(detect_multiple, -2))?;

    Ok(())
}
