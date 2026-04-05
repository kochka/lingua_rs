use lingua::Language;
use magnus::{Error, RArray, Ruby, Symbol};

use crate::helpers::value_to_string;

#[magnus::wrap(class = "Lingua::Language")]
pub struct WrappedLanguage(pub Language);

impl WrappedLanguage {
    pub fn lookup(value: magnus::Value) -> Result<Option<WrappedLanguage>, Error> {
        let input = value_to_string(value)?;
        Ok(crate::helpers::parse_language(&input).map(WrappedLanguage))
    }

    pub fn all() -> RArray {
        let ruby = Ruby::get().unwrap();
        let mut langs: Vec<Language> = Language::all().into_iter().collect();
        langs.sort_by(|a, b| a.to_string().cmp(&b.to_string()));
        let array = ruby.ary_new_capa(langs.len());
        for lang in langs {
            let _ = array.push(WrappedLanguage(lang));
        }
        array
    }

    pub fn names() -> RArray {
        let ruby = Ruby::get().unwrap();
        let mut langs: Vec<Language> = Language::all().into_iter().collect();
        langs.sort_by(|a, b| a.to_string().cmp(&b.to_string()));
        let array = ruby.ary_new_capa(langs.len());
        for lang in langs {
            let _ = array.push(lang.to_string());
        }
        array
    }

    pub fn iso_codes() -> RArray {
        let ruby = Ruby::get().unwrap();
        let mut langs: Vec<Language> = Language::all().into_iter().collect();
        langs.sort_by(|a, b| a.to_string().cmp(&b.to_string()));
        let array = ruby.ary_new_capa(langs.len());
        for lang in langs {
            let _ = array.push(lang.iso_code_639_1().to_string());
        }
        array
    }

    pub fn name(&self) -> String {
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
