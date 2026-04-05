mod confidence_result;
mod detector;
mod helpers;
mod language;
mod segment;

use magnus::{Error, RArray, RHash, Ruby, function, prelude::*};

use detector::{build_detector_from_options, compute_confidence, compute_confidence_values, compute_detect_multiple};
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

    helpers::define_errors(&module)?;
    language::define(ruby, &module)?;
    confidence_result::define(ruby, &module)?;
    segment::define(ruby, &module)?;
    detector::define(ruby, &module)?;

    module.define_singleton_method("detect", function!(detect, -2))?;
    module.define_singleton_method("confidence", function!(confidence, 2))?;
    module.define_singleton_method("confidence_values", function!(confidence_values, -2))?;
    module.define_singleton_method("detect_multiple", function!(detect_multiple, -2))?;

    Ok(())
}
