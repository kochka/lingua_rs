use lingua::Language;

use crate::language::WrappedLanguage;

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
