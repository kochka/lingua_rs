use lingua::Language;
use magnus::{Ruby, Symbol};

#[magnus::wrap(class = "Lingua::Language")]
pub struct WrappedLanguage(pub Language);

impl WrappedLanguage {
    pub fn to_s(&self) -> String {
        self.0.to_string()
    }

    pub fn to_iso6391(&self) -> String {
        self.0.iso_code_639_1().to_string()
    }

    pub fn to_iso6393(&self) -> String {
        self.0.iso_code_639_3().to_string()
    }

    pub fn to_sym(&self) -> Symbol {
        let ruby = Ruby::get().unwrap();
        ruby.to_symbol(&self.0.to_string().to_lowercase())
    }

    pub fn inspect(&self) -> String {
        format!("#<Lingua::Language {}>", self.0)
    }

    pub fn eq(&self, other: &WrappedLanguage) -> bool {
        self.0 == other.0
    }

    pub fn hash(&self) -> u64 {
        self.0 as u64
    }
}
