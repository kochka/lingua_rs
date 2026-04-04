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
    assert_raises(ArgumentError) do
      Lingua.detect('Hello', languages: %w[en zzzz])
    end
  end

  def test_invalid_language_error_message
    error = assert_raises(ArgumentError) do
      Lingua.detect('Hello', languages: %w[zzzz])
    end
    assert_match(/unknown language: "zzzz"/, error.message)
  end
end

class TestConfidence < Minitest::Test
  def test_returns_float
    score = Lingua.confidence('Guten Morgen allerseits', 'de')
    assert_instance_of Float, score
  end

  def test_high_confidence_for_matching_language
    score = Lingua.confidence('The quick brown fox jumps over the lazy dog', 'en')
    assert_operator score, :>, 0.1
  end

  def test_low_confidence_for_non_matching_language
    score = Lingua.confidence('The quick brown fox jumps over the lazy dog', 'ja')
    assert_operator score, :<, 0.1
  end

  def test_accepts_language_name
    score = Lingua.confidence('Esta es una prueba sencilla', 'Spanish')
    assert_operator score, :>, 0.1
  end

  def test_accepts_iso6393
    score = Lingua.confidence('Hoje esta um belo dia de sol', 'por')
    assert_operator score, :>, 0.1
  end

  def test_accepts_symbol
    score = Lingua.confidence('La vita e molto bella', :it)
    assert_operator score, :>, 0.1
  end

  def test_invalid_language_raises_error
    assert_raises(ArgumentError) do
      Lingua.confidence('Hello', 'zzzz')
    end
  end
end

class TestConfidenceValues < Minitest::Test
  def test_returns_array_of_confidence_results
    values = Lingua.confidence_values('Ich liebe dich', languages: %w[en de fr])
    assert_instance_of Array, values
    assert_instance_of Lingua::ConfidenceResult, values.first
    assert_instance_of Lingua::Language, values.first.language
    assert_instance_of Float, values.first.confidence
  end

  def test_first_result_is_most_confident
    values = Lingua.confidence_values('Je mange une pomme', languages: %w[en fr])
    assert_equal 'French', values.first.language.to_s
    assert_operator values.first.confidence, :>, values.last.confidence
  end

  def test_includes_all_requested_languages
    values = Lingua.confidence_values('Donde esta la biblioteca', languages: %w[es pt it])
    languages = values.map { |r| r.language.to_iso }.sort
    assert_equal %w[es it pt], languages
  end

  def test_confidences_sum_to_one
    values = Lingua.confidence_values('Wat een mooie dag vandaag', languages: %w[nl de en])
    total = values.sum(&:confidence)
    assert_in_delta 1.0, total, 0.01
  end

  def test_accepts_same_options_as_detect
    values = Lingua.confidence_values('Bom dia a todos',
                                      languages: %w[es pt],
                                      is_low_accuracy_mode_enabled: true)
    assert_equal 'Portuguese', values.first.language.to_s
  end

  def test_invalid_language_raises_error
    assert_raises(ArgumentError) do
      Lingua.confidence_values('Hello', languages: %w[zzzz])
    end
  end
end

class TestDetector < Minitest::Test
  def setup
    @detector = Lingua::Detector.new(languages: %w[en fr de])
  end

  def test_detect
    assert_equal 'French', @detector.detect('Bonjour le monde').to_s
  end

  def test_detect_reusable
    assert_equal 'French', @detector.detect('Bonjour le monde').to_s
    assert_equal 'English', @detector.detect('Hello world, this is a test').to_s
  end

  def test_detect_returns_nil_for_empty_input
    assert_nil @detector.detect('')
  end

  def test_confidence
    score = @detector.confidence('Bonjour le monde', :fr)
    assert_instance_of Float, score
    assert_operator score, :>, 0.1
  end

  def test_confidence_accepts_string
    score = @detector.confidence('Bonjour le monde', 'French')
    assert_operator score, :>, 0.1
  end

  def test_confidence_invalid_language
    assert_raises(ArgumentError) { @detector.confidence('Hello', 'zzzz') }
  end

  def test_confidence_values_returns_confidence_results
    results = @detector.confidence_values('Bonjour le monde')
    assert_instance_of Array, results
    assert_instance_of Lingua::ConfidenceResult, results.first
  end

  def test_confidence_values_first_is_most_confident
    results = @detector.confidence_values('Je mange une pomme')
    assert_equal 'French', results.first.language.to_s
  end

  def test_confidence_result_attributes
    result = @detector.confidence_values('Hallo Welt').first
    assert_instance_of Lingua::Language, result.language
    assert_instance_of Float, result.confidence
  end

  def test_confidence_result_to_s
    result = @detector.confidence_values('Bonjour').first
    assert_match(/\(\d+\.\d+\)/, result.to_s)
  end

  def test_confidence_result_inspect
    result = @detector.confidence_values('Bonjour').first
    assert_match(/#<Lingua::ConfidenceResult .+ \(\d+\.\d+\)>/, result.inspect)
  end

  def test_confidence_values_sum_to_one
    results = @detector.confidence_values('Bonjour le monde')
    total = results.sum(&:confidence)
    assert_in_delta 1.0, total, 0.01
  end

  def test_new_without_options
    detector = Lingua::Detector.new
    assert_equal 'French', detector.detect('Bonjour le monde').to_s
  end

  def test_with_low_accuracy_mode
    detector = Lingua::Detector.new(languages: %w[en fr], is_low_accuracy_mode_enabled: true)
    assert_equal 'French', detector.detect('Bonjour le monde').to_s
  end

  def test_invalid_language_raises_error
    assert_raises(ArgumentError) do
      Lingua::Detector.new(languages: %w[en zzzz])
    end
  end

  def test_not_instantiable_confidence_result
    assert_raises(TypeError) { Lingua::ConfidenceResult.new }
  end
end

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
end
