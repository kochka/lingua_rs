# frozen_string_literal: true

return unless ENV['BENCH']

require 'test_helper'
require 'benchmark'

class TestBenchmark < Minitest::Test
  TEXTS = ([
    'Bonjour le monde, comment allez-vous aujourd\'hui?',
    'Hello world, how are you doing today?',
    'Hallo Welt, wie geht es Ihnen heute?',
    'Hola mundo, como estas hoy en dia?',
    'Ciao mondo, come stai oggi?'
  ] * 20).freeze

  MIXED_TEXTS = [
    'Bonjour le monde. Hello world, how are you?',
    'Parlez-vous francais ? Ich spreche ein bisschen Deutsch.',
    'Ciao mondo. Hola mundo, como estas hoy?'
  ].freeze

  def setup
    @detector = Lingua::Detector.new(languages: %w[en fr de es it],
                                     is_every_language_model_preloaded: true)
  end

  def test_detect_vs_detect_batch
    compare :detect, TEXTS
  end

  def test_confidence_values_vs_batch
    compare :confidence_values, TEXTS
  end

  def test_detect_multiple_vs_batch
    compare :detect_multiple, MIXED_TEXTS
  end

  private

  def compare(name, texts, rounds: 100) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    batch_name = :"#{name}_batch"

    sequential = Benchmark.measure do
      rounds.times { texts.each { |t| @detector.send(name, t) } }
    end

    batched = Benchmark.measure do
      rounds.times { @detector.send(batch_name, texts) }
    end

    total = texts.size * rounds
    puts "\n  #{name} (#{total} texts):"
    puts "    Sequential: #{format('%.2fs', sequential.real)}"
    puts "    Batch:      #{format('%.2fs', batched.real)}"
    puts format('  Speedup: %.2fx', sequential.real / batched.real)
  end
end
