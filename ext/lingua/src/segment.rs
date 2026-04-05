use lingua::Language;

use crate::language::WrappedLanguage;

#[magnus::wrap(class = "Lingua::Segment")]
pub struct Segment {
    pub language: Language,
    pub start_index: usize,
    pub end_index: usize,
    pub word_count: usize,
    pub text: String,
}

impl Segment {
    pub fn language(&self) -> WrappedLanguage {
        WrappedLanguage(self.language)
    }

    pub fn start_index(&self) -> usize {
        self.start_index
    }

    pub fn end_index(&self) -> usize {
        self.end_index
    }

    pub fn word_count(&self) -> usize {
        self.word_count
    }

    pub fn text(&self) -> String {
        self.text.clone()
    }

    pub fn to_s(&self) -> String {
        format!("{} ({}-{}): {}", self.language, self.start_index, self.end_index, self.text)
    }

    pub fn inspect(&self) -> String {
        format!(
            "#<Lingua::Segment {} ({}-{}) \"{}\">",
            self.language, self.start_index, self.end_index, self.text
        )
    }
}
