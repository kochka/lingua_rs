# frozen_string_literal: true

require 'test_helper'

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
    assert_raises(Lingua::UnknownLanguageError) { @detector.confidence('Hello', 'zzzz') }
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
    assert_raises(Lingua::UnknownLanguageError) do
      Lingua::Detector.new(languages: %w[en zzzz])
    end
  end

  def test_not_instantiable_confidence_result
    assert_raises(TypeError) { Lingua::ConfidenceResult.new }
  end

  def test_empty_languages_raises_error
    assert_raises(ArgumentError) do
      Lingua::Detector.new(languages: [])
    end
  end

  def test_minimum_relative_distance_negative_raises_error
    assert_raises(ArgumentError) do
      Lingua::Detector.new(minimum_relative_distance: -0.1)
    end
  end

  def test_minimum_relative_distance_too_high_raises_error
    assert_raises(ArgumentError) do
      Lingua::Detector.new(minimum_relative_distance: 1.0)
    end
  end

  def test_minimum_relative_distance_valid
    detector = Lingua::Detector.new(languages: %w[en fr], minimum_relative_distance: 0.5)
    assert_instance_of Lingua::Detector, detector
  end
end
