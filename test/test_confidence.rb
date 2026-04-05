# frozen_string_literal: true

require 'test_helper'

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
    assert_raises(Lingua::UnknownLanguageError) do
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
    assert_raises(Lingua::UnknownLanguageError) do
      Lingua.confidence_values('Hello', languages: %w[zzzz])
    end
  end
end
