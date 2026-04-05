# frozen_string_literal: true

require 'test_helper'

class TestLanguage < Minitest::Test
  def setup
    @french = Lingua.detect('Bonjour le monde')
    @english = Lingua.detect('Hello world, this is a test')
  end

  def test_to_s
    assert_equal 'French', @french.to_s
    assert_equal 'English', @english.to_s
  end

  def test_to_iso6391
    assert_equal 'fr', @french.to_iso6391
    assert_equal 'en', @english.to_iso6391
  end

  def test_to_iso_is_alias_for_iso6391
    assert_equal @french.to_iso6391, @french.to_iso
  end

  def test_to_iso6393
    assert_equal 'fra', @french.to_iso6393
    assert_equal 'eng', @english.to_iso6393
  end

  def test_to_sym
    assert_equal :french, @french.to_sym
    assert_equal :english, @english.to_sym
  end

  def test_inspect
    assert_equal '#<Lingua::Language French>', @french.inspect
    assert_equal '#<Lingua::Language English>', @english.inspect
  end

  def test_equality
    other_french = Lingua.detect('Salut tout le monde', languages: %w[en fr])
    assert_equal @french, other_french
  end

  def test_inequality
    refute_equal @french, @english
  end

  def test_usable_as_hash_key
    other_french = Lingua.detect('Merci beaucoup mon ami', languages: %w[en fr])
    h = { @french => 'first' }
    h[other_french] = 'second'
    assert_equal 1, h.size
    assert_equal 'second', h[@french]
  end

  def test_not_instantiable
    assert_raises(TypeError) do
      Lingua::Language.new
    end
  end

  def test_lookup_by_name
    assert_equal 'French', Lingua::Language['French'].to_s
  end

  def test_lookup_by_iso6391_string
    assert_equal 'French', Lingua::Language['fr'].to_s
  end

  def test_lookup_by_iso6391_symbol
    assert_equal 'French', Lingua::Language[:fr].to_s
  end
end

class TestLanguageCollections < Minitest::Test
  def setup
    @french = Lingua.detect('Bonjour le monde')
    @english = Lingua.detect('Hello world, this is a test')
  end

  def test_lookup_by_iso6393
    assert_equal 'French', Lingua::Language['fra'].to_s
  end

  def test_lookup_returns_nil_for_unknown
    assert_nil Lingua::Language['xxx']
  end

  def test_all_returns_array_of_languages
    all = Lingua::Language.all
    assert_instance_of Array, all
    assert_instance_of Lingua::Language, all.first
    assert_includes all.map(&:to_s), 'French'
    assert_includes all.map(&:to_s), 'English'
  end

  def test_all_is_sorted
    all = Lingua::Language.all.map(&:to_s)
    assert_equal all.sort, all
  end

  def test_names_returns_strings
    names = Lingua::Language.names
    assert_instance_of Array, names
    assert_instance_of String, names.first
    assert_includes names, 'French'
    assert_includes names, 'English'
  end

  def test_codes_returns_iso6391_codes
    codes = Lingua::Language.iso_codes
    assert_instance_of Array, codes
    assert_includes codes, 'fr'
    assert_includes codes, 'en'
  end

  def test_iso_code_alias
    assert_equal @french.to_iso6391, @french.iso_code
  end

  def test_predicate_returns_true_for_matching_language
    assert @french.french?
    assert @english.english?
  end

  def test_predicate_returns_false_for_non_matching_language
    refute @french.english?
    refute @english.french?
  end

  def test_predicate_respond_to
    assert_respond_to @french, :french?
    assert_respond_to @french, :english?
  end

  def test_all_names_codes_same_size
    assert_equal Lingua::Language.all.size, Lingua::Language.names.size
    assert_equal Lingua::Language.all.size, Lingua::Language.iso_codes.size
  end
end
