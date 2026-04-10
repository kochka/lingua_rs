# frozen_string_literal: true

require 'test_helper'

class TestDetectBatch < Minitest::Test
  def setup
    @detector = Lingua::Detector.new(languages: %w[en fr de])
  end

  def test_detect_batch_returns_array
    results = @detector.detect_batch(['Bonjour le monde', 'Hello world'])
    assert_instance_of Array, results
    assert_equal 2, results.size
  end

  def test_detect_batch_detects_languages
    texts = ['Bonjour le monde', 'Hello world, this is a test', 'Hallo Welt, das ist ein Test']
    results = @detector.detect_batch(texts)
    assert_equal 'French', results[0].to_s
    assert_equal 'English', results[1].to_s
    assert_equal 'German', results[2].to_s
  end

  def test_detect_batch_returns_nil_for_empty_input
    results = @detector.detect_batch(['Bonjour le monde', ''])
    assert_equal 'French', results[0].to_s
    assert_nil results[1]
  end

  def test_detect_batch_empty_array
    results = @detector.detect_batch([])
    assert_empty results
  end
end

class TestDetectMultipleBatch < Minitest::Test
  SENTENCES = [
    'Parlez-vous français? Ich spreche Französisch nur ein bisschen.',
    'Hello world. Bonjour le monde.'
  ].freeze

  def setup
    @detector = Lingua::Detector.new(languages: %w[en fr de])
  end

  def test_returns_array_of_arrays
    results = @detector.detect_multiple_batch(SENTENCES)
    assert_instance_of Array, results
    assert_equal 2, results.size
    assert_instance_of Array, results[0]
    assert_instance_of Lingua::Segment, results[0].first
  end

  def test_detects_languages_in_each_text
    results = @detector.detect_multiple_batch(SENTENCES)
    first_languages = results[0].map { |s| s.language.to_s }
    assert_includes first_languages, 'French'
    assert_includes first_languages, 'German'
  end

  def test_empty_array
    results = @detector.detect_multiple_batch([])
    assert_empty results
  end
end

class TestConfidenceValuesBatch < Minitest::Test
  def setup
    @detector = Lingua::Detector.new(languages: %w[en fr de])
  end

  def test_returns_array_of_arrays
    results = @detector.confidence_values_batch(['Bonjour le monde', 'Hello world'])
    assert_instance_of Array, results
    assert_equal 2, results.size
    assert_instance_of Array, results[0]
    assert_instance_of Lingua::ConfidenceResult, results[0].first
  end

  def test_confidence_values_per_text
    results = @detector.confidence_values_batch(['Bonjour le monde', 'Hello world, this is a test'])
    assert_equal 'French', results[0].first.language.to_s
    assert_equal 'English', results[1].first.language.to_s
  end

  def test_confidences_sum_to_one
    results = @detector.confidence_values_batch(['Bonjour le monde'])
    total = results[0].sum(&:confidence)
    assert_in_delta 1.0, total, 0.01
  end

  def test_empty_array
    results = @detector.confidence_values_batch([])
    assert_empty results
  end
end

class TestConfidenceBatch < Minitest::Test
  def setup
    @detector = Lingua::Detector.new(languages: %w[en fr de])
  end

  def test_returns_array_of_floats
    results = @detector.confidence_batch(['Bonjour le monde', 'Hello world'], :fr)
    assert_instance_of Array, results
    assert_equal 2, results.size
    assert_instance_of Float, results[0]
  end

  def test_high_confidence_for_matching_language
    results = @detector.confidence_batch(['Bonjour le monde', 'Hello world, this is a test'], :fr)
    assert_operator results[0], :>, 0.1
  end

  def test_accepts_string_language
    results = @detector.confidence_batch(['Bonjour le monde'], 'French')
    assert_operator results[0], :>, 0.1
  end

  def test_invalid_language_raises_error
    assert_raises(Lingua::UnknownLanguageError) do
      @detector.confidence_batch(['Hello'], 'zzzz')
    end
  end

  def test_empty_array
    results = @detector.confidence_batch([], :fr)
    assert_empty results
  end
end
