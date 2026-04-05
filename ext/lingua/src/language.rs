use lingua::Language;
use magnus::{Error, RArray, RModule, Ruby, Symbol, function, method, prelude::*};

use crate::helpers::value_to_string;

pub fn define(ruby: &Ruby, module: &RModule) -> Result<(), Error> {
    let class = module.define_class("Language", ruby.class_object())?;
    class.undef_default_alloc_func();
    class.define_method("name", method!(WrappedLanguage::name, 0))?;
    class.define_method("to_s", method!(WrappedLanguage::name, 0))?;
    class.define_method("to_iso6391", method!(WrappedLanguage::to_iso6391, 0))?;
    class.define_method("to_iso", method!(WrappedLanguage::to_iso6391, 0))?;
    class.define_method("iso_code", method!(WrappedLanguage::to_iso6391, 0))?;
    class.define_method("to_iso6393", method!(WrappedLanguage::to_iso6393, 0))?;
    class.define_method("to_sym", method!(WrappedLanguage::to_sym, 0))?;
    class.define_method("inspect", method!(WrappedLanguage::inspect, 0))?;
    class.define_method("==", method!(WrappedLanguage::eq, 1))?;
    class.define_method("eql?", method!(WrappedLanguage::eq, 1))?;
    class.define_method("hash", method!(WrappedLanguage::hash, 0))?;
    class.define_singleton_method("[]", function!(WrappedLanguage::lookup, 1))?;
    class.define_singleton_method("all", function!(WrappedLanguage::all, 0))?;
    class.define_singleton_method("names", function!(WrappedLanguage::names, 0))?;
    class.define_singleton_method("iso_codes", function!(WrappedLanguage::iso_codes, 0))?;
    Ok(())
}

#[magnus::wrap(class = "Lingua::Language")]
pub struct WrappedLanguage(pub Language);

impl WrappedLanguage {
    pub fn lookup(value: magnus::Value) -> Result<Option<WrappedLanguage>, Error> {
        let input = value_to_string(value)?;
        Ok(crate::helpers::parse_language(&input).map(WrappedLanguage))
    }

    pub fn all() -> Result<RArray, Error> {
        let ruby = Ruby::get().unwrap();
        let mut langs: Vec<Language> = Language::all().into_iter().collect();
        langs.sort_by(|a, b| a.to_string().cmp(&b.to_string()));
        let array = ruby.ary_new_capa(langs.len());
        for lang in langs {
            array.push(WrappedLanguage(lang))?;
        }
        Ok(array)
    }

    pub fn names() -> Result<RArray, Error> {
        let ruby = Ruby::get().unwrap();
        let mut langs: Vec<Language> = Language::all().into_iter().collect();
        langs.sort_by(|a, b| a.to_string().cmp(&b.to_string()));
        let array = ruby.ary_new_capa(langs.len());
        for lang in langs {
            array.push(lang.to_string())?;
        }
        Ok(array)
    }

    pub fn iso_codes() -> Result<RArray, Error> {
        let ruby = Ruby::get().unwrap();
        let mut langs: Vec<Language> = Language::all().into_iter().collect();
        langs.sort_by(|a, b| a.to_string().cmp(&b.to_string()));
        let array = ruby.ary_new_capa(langs.len());
        for lang in langs {
            array.push(lang.iso_code_639_1().to_string())?;
        }
        Ok(array)
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
