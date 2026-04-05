# frozen_string_literal: true

module Lingua
  class Language
    private

    def respond_to_missing?(method_name, include_private = false)
      method_name.end_with?('?') || super
    end

    def method_missing(method_name, *args)
      if method_name.end_with?('?') && args.empty?
        match = Lingua::Language[method_name.name.delete_suffix('?')]
        !match.nil? && self == match
      else
        super
      end
    end
  end
end
