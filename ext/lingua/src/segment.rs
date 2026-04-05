use lingua::Language;
use magnus::{Error, RModule, Ruby, method, prelude::*};

use crate::language::WrappedLanguage;

pub fn define(ruby: &Ruby, module: &RModule) -> Result<(), Error> {
    let class = module.define_class("Segment", ruby.class_object())?;
    class.undef_default_alloc_func();
    class.define_method("language", method!(Segment::language, 0))?;
    class.define_method("start_index", method!(Segment::start_index, 0))?;
    class.define_method("end_index", method!(Segment::end_index, 0))?;
    class.define_method("word_count", method!(Segment::word_count, 0))?;
    class.define_method("text", method!(Segment::text, 0))?;
    class.define_method("to_s", method!(Segment::to_s, 0))?;
    class.define_method("inspect", method!(Segment::inspect, 0))?;
    Ok(())
}

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
