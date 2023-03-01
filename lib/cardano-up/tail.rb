# frozen_string_literal: true

module CardanoUp
  # Tail log file
  module Tail
    def self.tail(file_path, lines = nil)
      lines_back = lines || 10
      File.open(file_path) do |log|
        log.extend(File::Tail)
        log.interval
        log.backward(lines_back.to_i)
        log.tail { |line| warn line }
      end
    end
  end
end
