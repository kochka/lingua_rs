# frozen_string_literal: true

require 'test_helper'

class TestDetectMultipleLanguages < Minitest::Test
  SENTENCE = 'Parlez-vous français? Ich spreche Französisch nur ein bisschen. A little bit is better than nothing.'

  def test_returns_array_of_detection_results
    results = Lingua.detect_multiple(SENTENCE, languages: %w[en fr de])
    assert_instance_of Array, results
    assert_instance_of Lingua::Segment, results.first
  end

  def test_detects_three_languages
    results = Lingua.detect_multiple(SENTENCE, languages: %w[en fr de])
    languages = results.map { |r| r.language.to_s }
    assert_equal %w[French German English], languages
  end

  def test_detection_result_attributes
    results = Lingua.detect_multiple(SENTENCE, languages: %w[en fr de])
    first = results.first
    assert_instance_of Lingua::Language, first.language
    assert_instance_of Integer, first.start_index
    assert_instance_of Integer, first.end_index
    assert_instance_of Integer, first.word_count
    assert_instance_of String, first.text
  end

  def test_text_matches_indices
    results = Lingua.detect_multiple(SENTENCE, languages: %w[en fr de])
    results.each do |r|
      assert_equal SENTENCE[r.start_index...r.end_index], r.text
    end
  end

  def test_to_s
    results = Lingua.detect_multiple(SENTENCE, languages: %w[en fr de])
    assert_match(/French \(\d+-\d+\)/, results.first.to_s)
  end

  def test_inspect
    results = Lingua.detect_multiple(SENTENCE, languages: %w[en fr de])
    assert_match(/#<Lingua::Segment French/, results.first.inspect)
  end

  def test_not_instantiable
    assert_raises(TypeError) { Lingua::Segment.new }
  end

  def test_detector_detect_multiple
    detector = Lingua::Detector.new(languages: %w[en fr de])
    results = detector.detect_multiple(SENTENCE)
    languages = results.map { |r| r.language.to_s }
    assert_equal %w[French German English], languages
  end
end
