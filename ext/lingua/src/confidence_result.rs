use lingua::Language;
use magnus::{Error, RModule, Ruby, method, prelude::*};

use crate::language::WrappedLanguage;

pub fn define(ruby: &Ruby, module: &RModule) -> Result<(), Error> {
    let class = module.define_class("ConfidenceResult", ruby.class_object())?;
    class.undef_default_alloc_func();
    class.define_method("language", method!(ConfidenceResult::language, 0))?;
    class.define_method("confidence", method!(ConfidenceResult::confidence, 0))?;
    class.define_method("to_s", method!(ConfidenceResult::to_s, 0))?;
    class.define_method("inspect", method!(ConfidenceResult::inspect, 0))?;
    Ok(())
}

#[magnus::wrap(class = "Lingua::ConfidenceResult")]
pub struct ConfidenceResult {
    pub language: Language,
    pub confidence: f64,
}

impl ConfidenceResult {
    pub fn language(&self) -> WrappedLanguage {
        WrappedLanguage(self.language)
    }

    pub fn confidence(&self) -> f64 {
        self.confidence
    }

    pub fn to_s(&self) -> String {
        format!("{} ({:.2})", self.language, self.confidence)
    }

    pub fn inspect(&self) -> String {
        format!(
            "#<Lingua::ConfidenceResult {} ({:.4})>",
            self.language, self.confidence
        )
    }
}
