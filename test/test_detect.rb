# frozen_string_literal: true

require 'test_helper'

class TestDetect < Minitest::Test
  def test_version
    refute_nil Lingua::VERSION
  end

  def test_detect_french
    lang = Lingua.detect('Bonjour le monde')
    assert_equal 'French', lang.to_s
  end

  def test_detect_english
    lang = Lingua.detect('Hello world, this is a test')
    assert_equal 'English', lang.to_s
  end

  def test_detect_german
    lang = Lingua.detect('Hallo Welt, das ist ein Test')
    assert_equal 'German', lang.to_s
  end

  def test_detect_returns_nil_for_empty_input
    assert_nil Lingua.detect('')
  end

  def test_detect_returns_language_object
    lang = Lingua.detect('La vita e bella')
    assert_instance_of Lingua::Language, lang
  end

  def test_languages_filter_by_name
    lang = Lingua.detect('Ich bin ein Berliner', languages: %w[English German])
    assert_equal 'German', lang.to_s
  end

  def test_languages_filter_by_iso6391
    lang = Lingua.detect('Esta es una prueba', languages: %w[en es pt])
    assert_equal 'Spanish', lang.to_s
  end

  def test_languages_filter_by_iso6393
    lang = Lingua.detect('Hoje esta um belo dia', languages: %w[spa por fra])
    assert_equal 'Portuguese', lang.to_s
  end

  def test_languages_filter_mixed_formats
    lang = Lingua.detect('Ciao mondo, come stai', languages: %w[fr ita English])
    assert_equal 'Italian', lang.to_s
  end

  def test_languages_option_with_symbol_key
    lang = Lingua.detect('Det er en god dag', languages: %w[da sv nb])
    assert_equal 'Danish', lang.to_s
  end

  def test_languages_option_with_string_key
    lang = Lingua.detect('To jest dobry dzien', 'languages' => %w[pl cs sk])
    assert_equal 'Polish', lang.to_s
  end

  def test_low_accuracy_mode
    lang = Lingua.detect('Je suis content de vous voir',
                         languages: %w[en fr],
                         is_low_accuracy_mode_enabled: true)
    assert_equal 'French', lang.to_s
  end

  def test_invalid_language_raises_error
    assert_raises(Lingua::UnknownLanguageError) do
      Lingua.detect('Hello', languages: %w[en zzzz])
    end
  end

  def test_invalid_language_error_message
    error = assert_raises(Lingua::UnknownLanguageError) do
      Lingua.detect('Hello', languages: %w[zzzz])
    end
    assert_match(/unknown language: "zzzz"/, error.message)
  end

  def test_unknown_language_error_is_argument_error
    assert_raises(ArgumentError) do
      Lingua.detect('Hello', languages: %w[zzzz])
    end
  end
end
